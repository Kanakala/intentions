import Foundation

class DataStore: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var reflections: [DailyReflection] = []
    
    private let goalsKey = "saved_goals"
    private let reflectionsKey = "saved_reflections"
    private var reorderWorkItem: DispatchWorkItem?
    
    init() {
        loadData()
    }
    
    func saveGoal(_ goal: Goal) {
        var newGoal = goal
        newGoal.order = goals.count // Assign next order number
        goals.append(newGoal)
        saveData()
    }
    
    func saveReflection(_ reflection: DailyReflection) {
        reflections.append(reflection)
        saveData()
    }
    
    func getReflectionsForGoal(_ goalId: UUID) -> [DailyReflection] {
        return reflections.filter { $0.goalId == goalId }
            .sorted { $0.date > $1.date }
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
            goals[idx] = updatedGoal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        reflections.removeAll { $0.goalId == goal.id }
        saveData()
    }
    
    func archiveGoal(_ goal: Goal) {
        if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[idx].isArchived = true
            saveData()
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
        saveData()
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
                self.saveData()
            }
        }
        
        reorderWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    var sortedGoals: [Goal] {
        return goals.sorted { first, second in
            if first.order != second.order {
                return first.order < second.order
            }
            return first.createdAt < second.createdAt
        }
    }
    
    private func saveData() {
        if let encodedGoals = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encodedGoals, forKey: goalsKey)
        }
        
        if let encodedReflections = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encodedReflections, forKey: reflectionsKey)
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
                saveData()
            }
        }
        
        if let savedReflections = UserDefaults.standard.data(forKey: reflectionsKey),
           let decodedReflections = try? JSONDecoder().decode([DailyReflection].self, from: savedReflections) {
            reflections = decodedReflections
        }
    }
} 
