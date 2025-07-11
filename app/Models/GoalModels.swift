import Foundation

// MARK: - Core Models
struct Goal: Identifiable, Codable {
    let id: UUID
    var intention: String
    var selectedOptions: Set<GoalOption>
    var createdAt: Date
    var lastReflectionDate: Date?
    var streakCount: Int
    var reminderTime: Date?
    var isArchived: Bool
    var imageName: String? // Optional image name for intention card
    var order: Int // For maintaining card order
    
    // Computed property for dailyActions
    var dailyActions: [DailyAction] {
        selectedOptions.map { DailyAction(from: $0) }
    }
    
    init(intention: String, selectedOptions: Set<GoalOption>, reminderTime: Date? = nil, isArchived: Bool = false, imageName: String? = nil, order: Int = 0) {
        self.id = UUID()
        self.intention = intention
        self.selectedOptions = selectedOptions
        self.createdAt = Date()
        self.streakCount = 0
        self.reminderTime = reminderTime
        self.isArchived = isArchived
        self.imageName = imageName
        self.order = order
    }
}

// MARK: - Daily Reflection Models
struct DailyReflection: Identifiable, Codable {
    let id: UUID
    let goalId: UUID
    let date: Date
    var responses: [DailyActionResponse]
    var mood: Mood?
    
    init(goalId: UUID) {
        self.id = UUID()
        self.goalId = goalId
        self.date = Date()
        self.responses = []
    }
}

enum Mood: String, Codable, CaseIterable {
    case calm = "Calm"
    case energetic = "Energetic"
    case focused = "Focused"
    case tired = "Tired"
    case stressed = "Stressed"
    
    var emoji: String {
        switch self {
        case .calm: return "😌"
        case .energetic: return "⚡️"
        case .focused: return "🎯"
        case .tired: return "😴"
        case .stressed: return "😰"
        }
    }
}

// MARK: - Action Models
struct DailyAction: Identifiable, Codable {
    let id: String
    let type: ActionType
    let prompt: String
    let frequency: Frequency
    var configuration: ActionConfiguration
    
    init(from option: GoalOption) {
        self.id = option.rawValue // Use GoalOption.rawValue for stable ID
        self.type = option.actionType
        self.prompt = option.description
        self.frequency = option.frequency
        self.configuration = option.configuration
    }
}

enum ActionType: String, Codable {
    case scale = "scale"
    case text = "text"
    case number = "number"
    case check = "check"
}

enum Frequency: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

struct ActionConfiguration: Codable {
    var range: ClosedRange<Int>?
    var unit: String?
    var placeholder: String?
    var maxLength: Int?
}

struct DailyActionResponse: Identifiable, Codable {
    let id: UUID
    let actionId: String // Changed from UUID to String
    let value: String
    let timestamp: Date
}

// MARK: - Goal Option Models
enum GoalOption: String, CaseIterable, Identifiable, Codable {
    case dailyReflection = "Daily Reflection"
    case journalEntry = "Journal Entry"
    case morningReminder = "Morning Reminder"
    case weeklyCheck = "Weekly Check"
    case celebrateWins = "Celebrate Wins"
    
    var id: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .dailyReflection: return "📊"
        case .journalEntry: return "📝"
        case .morningReminder: return "🌅"
        case .weeklyCheck: return "📈"
        case .celebrateWins: return "🎉"
        }
    }
    
    var description: String {
        switch self {
        case .dailyReflection: return "A single daily reflection (1–5 scale)"
        case .journalEntry: return "A one-line journal at night"
        case .morningReminder: return "A gentle morning reminder of my why"
        case .weeklyCheck: return "A weekly self-check with my progress story"
        case .celebrateWins: return "A space to celebrate small wins"
        }
    }
    
    var actionType: ActionType {
        switch self {
        case .dailyReflection: return .scale
        case .journalEntry: return .text
        case .morningReminder: return .check
        case .weeklyCheck: return .number
        case .celebrateWins: return .text
        }
    }
    
    var frequency: Frequency {
        switch self {
        case .dailyReflection, .journalEntry, .morningReminder: return .daily
        case .weeklyCheck: return .weekly
        case .celebrateWins: return .daily
        }
    }
    
    var configuration: ActionConfiguration {
        switch self {
        case .dailyReflection:
            return ActionConfiguration(range: 1...10)
        case .journalEntry:
            return ActionConfiguration(placeholder: "How did you feel about your choices today?", maxLength: 280)
        case .morningReminder:
            return ActionConfiguration()
        case .weeklyCheck:
            return ActionConfiguration(unit: "kg", placeholder: "Enter your current weight")
        case .celebrateWins:
            return ActionConfiguration(placeholder: "What small win can you celebrate today?", maxLength: 100)
        }
    }
} 