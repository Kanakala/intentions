import Foundation
import UIKit

class DataStore: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var reflections: [DailyReflection] = []
    
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
        scheduleSave()
    }
    
    func saveReflection(_ reflection: DailyReflection) {
        reflections.append(reflection)
        scheduleSave()
    }
    
    func getReflectionsForGoal(_ goalId: UUID) -> [DailyReflection] {
        return reflections.filter { $0.goalId == goalId }
            .sorted { $0.date > $1.date }
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
            goals[idx] = updatedGoal
            scheduleSave()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        reflections.removeAll { $0.goalId == goal.id }
        scheduleSave()
    }
    
    func archiveGoal(_ goal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[idx].isArchived = true
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
                scheduleSave()
            }
        }
        
        if let savedReflections = UserDefaults.standard.data(forKey: reflectionsKey),
           let decodedReflections = try? JSONDecoder().decode([DailyReflection].self, from: savedReflections) {
            reflections = decodedReflections
        }
    }
} 
