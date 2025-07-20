import Foundation
import UIKit

/// DataStore with comprehensive performance optimizations
/// Eliminates N+1 queries, redundant computations, and expensive UI calculations
class DataStore: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var reflections: [DailyReflection] = []
    
    // Performance optimization: Cached reflection lookups
    private var reflectionsByGoal: [UUID: [DailyReflection]] = [:]
    private var lastReflectionByGoal: [UUID: DailyReflection] = [:]
    private var weeklyProgressByGoal: [UUID: Double] = [:]
    private var reflectionsCacheVersion = 0
    
    // Performance optimization: Cached display computations
    private var displayStatusByGoal: [UUID: GoalDisplayStatus] = [:]
    private var displayCacheVersion = 0
    
    // Cached formatters for performance
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private lazy var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    // Cached image loading for performance
    private var imageCache: [String: UIImage?] = [:]
    
    /// Efficiently retrieves images with caching to avoid repeated asset loading.
    /// Returns cached UIImage or loads and caches new image for future use.
    func getCachedImage(named imageName: String?) -> UIImage? {
        guard let imageName = imageName else { return nil }
        
        if let cachedImage = imageCache[imageName] {
            return cachedImage
        }
        
        let image = UIImage(named: imageName)
        imageCache[imageName] = image
        return image
    }
    
    private let goalsKey = "saved_goals"
    private let reflectionsKey = "saved_reflections"
    private var reorderWorkItem: DispatchWorkItem?
    private var saveWorkItem: DispatchWorkItem?
    private let saveDebounceInterval: TimeInterval = 0.5
    
    init() {
        loadData()
        setupAppLifecycleObservers()
    }
    
    deinit {
        // Force save any pending changes when DataStore is deallocated
        forceSave()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appWillResignActive() {
        // Force save when app goes to background to prevent data loss
        forceSave()
    }
    
    func saveGoal(_ goal: Goal) {
        var newGoal = goal
        newGoal.order = goals.count // Assign next order number
        goals.append(newGoal)
        invalidateDisplayCache()
        scheduleSave()
    }
    
    func saveReflection(_ reflection: DailyReflection) {
        reflections.append(reflection)
        invalidateReflectionCache()
        invalidateDisplayCache()
        scheduleSave()
    }
    
    // MARK: - Optimized Reflection Lookups
    /// Efficiently retrieves reflections for a specific goal using cached indexes.
    /// Performance: O(1) lookup vs O(n) filtering for each access.
    func getReflectionsForGoal(_ goalId: UUID) -> [DailyReflection] {
        ensureReflectionCacheValid()
        return reflectionsByGoal[goalId] ?? []
    }
    
    /// Efficiently retrieves the most recent reflection for a goal.
    /// Performance: O(1) lookup vs O(n) filtering + sorting for each access.
    func getLastReflectionForGoal(_ goalId: UUID) -> DailyReflection? {
        ensureReflectionCacheValid()
        return lastReflectionByGoal[goalId]
    }
    
    /// Efficiently retrieves pre-calculated weekly progress for a goal.
    /// Performance: O(1) lookup vs O(n) filtering + date calculation for each access.
    func getWeeklyProgressForGoal(_ goalId: UUID) -> Double {
        ensureReflectionCacheValid()
        return weeklyProgressByGoal[goalId] ?? 0.0
    }
    
    /// Efficiently retrieves total reflection count for a goal.
    /// Performance: O(1) lookup vs O(n) filtering + counting for each access.
    func getReflectionCountForGoal(_ goalId: UUID) -> Int {
        ensureReflectionCacheValid()
        return reflectionsByGoal[goalId]?.count ?? 0
    }
    
    // MARK: - Optimized Display Data
    /// Efficiently retrieves pre-computed display status for a goal.
    /// Includes formatted dates, progress percentages, and status flags.
    func getDisplayStatusForGoal(_ goalId: UUID) -> GoalDisplayStatus {
        ensureDisplayCacheValid()
        return displayStatusByGoal[goalId] ?? .empty
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
            goals[idx] = updatedGoal
            invalidateDisplayCache()
            scheduleSave()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        reflections.removeAll { $0.goalId == goal.id }
        invalidateReflectionCache()
        invalidateDisplayCache()
        scheduleSave()
    }
    
    func archiveGoal(_ goal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[idx].isArchived = true
            invalidateDisplayCache()
            scheduleSave()
        }
    }
    
    func duplicateGoal(_ goal: Goal) {
        let newGoal = Goal(
            intention: goal.intention,
            selectedOptions: goal.selectedOptions,
            reminderTime: goal.reminderTime,
            isArchived: false
        )
        goals.append(newGoal)
        invalidateDisplayCache()
        scheduleSave()
    }
    
    func reorderGoals(from source: IndexSet, to destination: Int) {
        guard !source.isEmpty else { return }
        
        // Cancel any pending reorder operations
        reorderWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // Simple direct reorder of the goals array
            self.goals.move(fromOffsets: source, toOffset: destination)
            
            // Update order values to match new positions
            for (index, goal) in self.goals.enumerated() {
                var updatedGoal = goal
                updatedGoal.order = index
                self.goals[index] = updatedGoal
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.invalidateDisplayCache()
                self.scheduleSave()
            }
        }
        
        reorderWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    // MARK: - Debounced Saving
    /// Schedules a save operation with debouncing to prevent excessive disk I/O.
    /// Multiple calls within the debounce interval will be batched into a single save.
    private func scheduleSave() {
        // Cancel any pending save operations
        saveWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.saveData()
        }
        
        saveWorkItem = workItem
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + saveDebounceInterval, execute: workItem)
    }
    
    /// Forces an immediate save, canceling any pending debounced saves.
    /// Used when app goes to background or DataStore is deallocated.
    func forceSave() {
        saveWorkItem?.cancel()
        saveData()
    }
    
    var sortedGoals: [Goal] {
        return goals.sorted { first, second in
            if first.order != second.order {
                return first.order < second.order
            }
            return first.createdAt < second.createdAt
        }
    }
    
    /// Performs the actual data persistence to UserDefaults.
    /// JSON encoding is done on a background thread to avoid blocking the main thread.
    /// UserDefaults writes are performed on main thread as they're thread-safe and fast.
    private func saveData() {
        // Perform encoding and saving on background queue
        let goalsToSave = goals
        let reflectionsToSave = reflections
        
        DispatchQueue.global(qos: .utility).async {
            // Encode data on background thread
            let encodedGoals = try? JSONEncoder().encode(goalsToSave)
            let encodedReflections = try? JSONEncoder().encode(reflectionsToSave)
            
            // Write to UserDefaults on main thread (UserDefaults is thread-safe but UI updates aren't)
            DispatchQueue.main.async {
                if let encodedGoals = encodedGoals {
                    UserDefaults.standard.set(encodedGoals, forKey: self.goalsKey)
                }
                
                if let encodedReflections = encodedReflections {
                    UserDefaults.standard.set(encodedReflections, forKey: self.reflectionsKey)
                }
            }
        }
    }
    
    private func loadData() {
        if let savedGoals = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: savedGoals) {
            goals = decodedGoals
            
            // Assign order values to existing goals that don't have them
            var needsUpdate = false
            for (index, goal) in goals.enumerated() {
                if goal.order == 0 && index > 0 {
                    var updatedGoal = goal
                    updatedGoal.order = index
                    goals[index] = updatedGoal
                    needsUpdate = true
                }
            }
            
            // Sort goals by their order property to maintain display order
            goals.sort { $0.order < $1.order }
            
            // Save updated goals if we made changes
            if needsUpdate {
                invalidateDisplayCache()
                scheduleSave()
            }
        }
        
        if let savedReflections = UserDefaults.standard.data(forKey: reflectionsKey),
           let decodedReflections = try? JSONDecoder().decode([DailyReflection].self, from: savedReflections) {
            reflections = decodedReflections
            invalidateReflectionCache() // Invalidate cache when loading new data
            invalidateDisplayCache()
        }
    }
    
    // MARK: - Reflection Cache Management
    /// Marks the reflection cache as invalid, forcing a rebuild on next access.
    /// Called whenever reflections are added, removed, or modified.
    private func invalidateReflectionCache() {
        reflectionsCacheVersion += 1
    }
    
    /// Ensures reflection cache is up-to-date, rebuilding if necessary.
    /// Uses Dictionary grouping for O(n) rebuilding vs O(n²) repeated filtering.
    private func ensureReflectionCacheValid() {
        // Only rebuild cache if it's been invalidated
        if reflectionsCacheVersion == 0 { return }
        
        // Clear existing cache
        reflectionsByGoal.removeAll()
        lastReflectionByGoal.removeAll()
        weeklyProgressByGoal.removeAll()
        
        // Build grouped reflections by goal
        let groupedReflections = Dictionary(grouping: reflections) { $0.goalId }
        
        // Process each goal's reflections
        for (goalId, goalReflections) in groupedReflections {
            // Sort reflections by date (newest first)
            let sortedReflections = goalReflections.sorted { $0.date > $1.date }
            reflectionsByGoal[goalId] = sortedReflections
            
            // Cache last reflection
            lastReflectionByGoal[goalId] = sortedReflections.first
            
            // Calculate weekly progress (simple approach)
            let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
            let weekReflections = sortedReflections.filter { $0.date >= weekStart }
            weeklyProgressByGoal[goalId] = Double(weekReflections.count) / 5.0 // Assuming 5-day target
        }
        
        // Mark cache as valid
        reflectionsCacheVersion = 0
    }
    
    // MARK: - Display Cache Management
    /// Marks the display cache as invalid, forcing a rebuild on next access.
    /// Called whenever reflections are added, removed, or modified.
    private func invalidateDisplayCache() {
        displayCacheVersion += 1
    }
    
    /// Ensures display cache is up-to-date, rebuilding if necessary.
    /// Uses Dictionary grouping for O(n) rebuilding vs O(n²) repeated filtering.
    private func ensureDisplayCacheValid() {
        // Only rebuild cache if it's been invalidated
        if displayCacheVersion == 0 { return }
        
        // Clear existing cache
        displayStatusByGoal.removeAll()
        
        // Build display status for each goal
        for goal in goals {
            let goalId = goal.id
            let lastReflection = getLastReflectionForGoal(goalId)
            let weeklyProgress = getWeeklyProgressForGoal(goalId)
            
            let displayStatus = GoalDisplayStatus(
                goal: goal,
                lastReflection: lastReflection,
                weeklyProgress: weeklyProgress,
                dateFormatter: dateFormatter,
                percentageFormatter: percentageFormatter
            )
            displayStatusByGoal[goalId] = displayStatus
        }
        
        // Mark cache as valid
        displayCacheVersion = 0
    }
} 
