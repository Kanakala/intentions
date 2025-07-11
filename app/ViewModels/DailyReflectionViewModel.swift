import Foundation
import Combine
import os.log

class DailyReflectionViewModel: ObservableObject {
    @Published var currentGoal: Goal?
    @Published var currentReflection: DailyReflection?
    @Published var isLoading = false
    @Published var showSuccessAnimation = false
    @Published var streakMessage: String?
    @Published var actionResponses: [String: String] = [:] // Keyed by action.id
    
    private var cancellables = Set<AnyCancellable>()
    private let logger: os.Logger = os.Logger(subsystem: "com.yourapp", category: "DailyReflection")
    
    init(goal: Goal) {
        self.currentGoal = goal
        self.currentReflection = DailyReflection(goalId: goal.id)
    }
    
    func submitResponse(for action: DailyAction, value: String) {
        actionResponses[action.id] = value
        // Optionally update currentReflection if needed for legacy code
        // No longer mutating currentReflection.responses directly for UI
        objectWillChange.send()
    }
    
    func isReflectionComplete() -> Bool {
        guard let goal = currentGoal else {
            logger.error("No current goal available")
            return false
        }
        let requiredActions = goal.dailyActions.count
        let completedResponses = goal.dailyActions.filter { actionResponses[$0.id]?.isEmpty == false }.count
        return completedResponses == requiredActions
    }
    
    func submitReflection(completion: @escaping (DailyReflection) -> Void) {
        guard let goal = currentGoal, isReflectionComplete() else {
            logger.error("Cannot submit reflection - not complete or no reflection available")
            return
        }
        isLoading = true
        // Build DailyReflection from actionResponses
        let responses: [DailyActionResponse] = goal.dailyActions.compactMap { action in
            guard let value = actionResponses[action.id], !value.isEmpty else { return nil }
            return DailyActionResponse(
                id: UUID(),
                actionId: action.id,
                value: value,
                timestamp: Date()
            )
        }
        var reflection = DailyReflection(goalId: goal.id)
        reflection.responses = responses
        reflection.mood = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {
                self?.logger.error("Self was deallocated during submission")
                return
            }
            // Update goal streak
            if var goal = self.currentGoal {
                goal.lastReflectionDate = Date()
                goal.streakCount += 1
                self.currentGoal = goal
                // Generate streak message
                self.streakMessage = self.generateStreakMessage(streak: goal.streakCount)
            }
            // Update state on main thread
            DispatchQueue.main.async {
                self.isLoading = false
                self.showSuccessAnimation = true
                // Call completion with the reflection
                completion(reflection)
            }
        }
    }
    
    private func generateStreakMessage(streak: Int) -> String {
        let message: String
        switch streak {
        case 1: message = "First day of your journey! 🌱"
        case 2: message = "Two days in a row! Keep going! 🌿"
        case 3: message = "Three days strong! You're building momentum! 🌳"
        case 7: message = "A week of consistency! Amazing work! 🌟"
        case 14: message = "Two weeks! You're making this a habit! 🎯"
        case 30: message = "A month of dedication! You're incredible! 🏆"
        default:
            message = "\(streak) days in a row! Keep the momentum! 💪"
        }
        return message
    }
    
    func resetReflection() {
        actionResponses = [:]
        currentReflection = DailyReflection(goalId: currentGoal?.id ?? UUID())
        showSuccessAnimation = false
        streakMessage = nil
    }
} 