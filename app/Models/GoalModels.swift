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

// MARK: - Intention Draft Models (for AI-assisted creation)
struct IntentionDraft {
    var title: String = ""
    var reminderTime: Date? = nil
    var repeatPattern: RepeatPattern = .none
    var durationInMinutes: Int? = nil
    var checkInPrompt: String? = nil
    var selectedOptions: Set<GoalOption> = [.dailyReflection]
    var imageName: String? = nil
}

enum RepeatPattern: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .none: return "No repeat"
        case .daily: return "Every day"
        case .weekly: return "Every week"
        case .monthly: return "Every month"
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date = Date()
    
    static func user(_ content: String) -> ChatMessage {
        ChatMessage(content: content, isUser: true)
    }
    
    static func bot(_ content: String) -> ChatMessage {
        ChatMessage(content: content, isUser: false)
    }
}

struct IntentUpdates {
    var title: String?
    var reminderTime: Date?
    var repeatPattern: RepeatPattern?
    var durationInMinutes: Int?
    var checkInPrompt: String?
    var selectedOptions: Set<GoalOption>?
    
    var summary: String {
        var parts: [String] = []
        if let title = title { parts.append("title: \(title)") }
        if let _ = reminderTime { parts.append("reminder time") }
        if let pattern = repeatPattern { parts.append("frequency: \(pattern.description)") }
        if let duration = durationInMinutes { parts.append("duration: \(duration) minutes") }
        if let options = selectedOptions { parts.append("\(options.count) tracking options") }
        return parts.joined(separator: ", ")
    }
} 

// MARK: - Chat Intent Parser
struct ChatIntentParser {
    static func parse(_ input: String) -> IntentUpdates {
        let lowercased = input.lowercased()
        var updates = IntentUpdates()
        
        // Parse title/intention
        if let titleMatch = extractTitle(from: lowercased) {
            updates.title = titleMatch
        }
        
        // Parse time
        if let timeMatch = extractTime(from: lowercased) {
            updates.reminderTime = timeMatch
        }
        
        // Parse frequency
        if let frequencyMatch = extractFrequency(from: lowercased) {
            updates.repeatPattern = frequencyMatch
        }
        
        // Parse duration
        if let durationMatch = extractDuration(from: lowercased) {
            updates.durationInMinutes = durationMatch
        }
        
        // Parse tracking options
        if let optionsMatch = extractTrackingOptions(from: lowercased) {
            updates.selectedOptions = optionsMatch
        }
        
        return updates
    }
    
    private static func extractTitle(from input: String) -> String? {
        // Look for patterns like "I want to...", "remind me to...", etc.
        let patterns = [
            "i want to (.+?)(?:every|daily|at|$)",
            "remind me to (.+?)(?:every|daily|at|$)",
            "help me (.+?)(?:every|daily|at|$)",
            "track (.+?)(?:every|daily|at|$)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
               let range = Range(match.range(at: 1), in: input) {
                return String(input[range]).trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
    
    private static func extractTime(from input: String) -> Date? {
        let timePatterns = [
            "(\\d{1,2})\\s*am",
            "(\\d{1,2})\\s*pm",
            "at (\\d{1,2})",
            "(\\d{1,2}):(\\d{2})"
        ]
        
        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) {
                
                if let hourRange = Range(match.range(at: 1), in: input),
                   let hour = Int(String(input[hourRange])) {
                    
                    var adjustedHour = hour
                    if input.contains("pm") && hour != 12 {
                        adjustedHour += 12
                    } else if input.contains("am") && hour == 12 {
                        adjustedHour = 0
                    }
                    
                    let calendar = Calendar.current
                    let components = DateComponents(hour: adjustedHour, minute: 0)
                    return calendar.date(from: components)
                }
            }
        }
        return nil
    }
    
    private static func extractFrequency(from input: String) -> RepeatPattern? {
        if input.contains("daily") || input.contains("every day") {
            return .daily
        } else if input.contains("weekly") || input.contains("every week") {
            return .weekly
        } else if input.contains("monthly") || input.contains("every month") {
            return .monthly
        }
        return nil
    }
    
    private static func extractDuration(from input: String) -> Int? {
        let durationPattern = "(\\d+)\\s*minutes?"
        if let regex = try? NSRegularExpression(pattern: durationPattern),
           let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
           let range = Range(match.range(at: 1), in: input) {
            return Int(String(input[range]))
        }
        return nil
    }
    
    private static func extractTrackingOptions(from input: String) -> Set<GoalOption>? {
        var options: Set<GoalOption> = []
        
        if input.contains("journal") || input.contains("write") {
            options.insert(.journalEntry)
        }
        if input.contains("celebrate") || input.contains("wins") {
            options.insert(.celebrateWins)
        }
        if input.contains("reminder") || input.contains("morning") {
            options.insert(.morningReminder)
        }
        if input.contains("weekly check") || input.contains("progress") {
            options.insert(.weeklyCheck)
        }
        
        // Always include daily reflection as default
        options.insert(.dailyReflection)
        
        return options.isEmpty ? nil : options
    }
} 

// MARK: - Filter and Sort Models
enum GoalSortOption: String, CaseIterable, Identifiable {
    case manual = "Manual Order"
    case newest = "Newest First"
    case oldest = "Oldest First"
    case alphabetical = "A to Z"
    case alphabeticalReverse = "Z to A"
    case streakHigh = "Highest Streak"
    case streakLow = "Lowest Streak"
    case mostActive = "Most Active"
    case leastActive = "Least Active"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .manual: return "hand.draw"
        case .newest: return "calendar.badge.plus"
        case .oldest: return "calendar"
        case .alphabetical: return "textformat.abc"
        case .alphabeticalReverse: return "textformat.abc"
        case .streakHigh: return "flame.fill"
        case .streakLow: return "flame"
        case .mostActive: return "chart.line.uptrend.xyaxis"
        case .leastActive: return "chart.line.downtrend.xyaxis"
        }
    }
}

enum GoalFilterOption: String, CaseIterable, Identifiable {
    case all = "All Intentions"
    case active = "Active Only"
    case archived = "Archived Only"
    case loggedToday = "Logged Today"
    case notLoggedToday = "Not Logged Today"
    case hasStreak = "Has Streak"
    case noStreak = "No Streak"
    case hasReminder = "Has Reminder"
    case noReminder = "No Reminder"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .all: return "list.bullet"
        case .active: return "checkmark.circle"
        case .archived: return "archivebox"
        case .loggedToday: return "checkmark.circle.fill"
        case .notLoggedToday: return "circle"
        case .hasStreak: return "flame.fill"
        case .noStreak: return "flame"
        case .hasReminder: return "bell.fill"
        case .noReminder: return "bell.slash"
        }
    }
}

struct IntentionsFilterState {
    var searchText: String = ""
    var sortOption: GoalSortOption = .manual
    var filterOption: GoalFilterOption = .active
    var showFilterPanel: Bool = false
}

// MARK: - Cached Display Data
struct GoalDisplayStatus {
    let isLoggedToday: Bool
    let formattedLastReflectionDate: String?
    let progressPercentage: String
    let progressValue: Double
    let hasAnyReflections: Bool
    let lastReflectionMoodEmoji: String?
    
    // Memberwise initializer for computed values
    init(isLoggedToday: Bool, formattedLastReflectionDate: String?, progressPercentage: String, progressValue: Double, hasAnyReflections: Bool, lastReflectionMoodEmoji: String?) {
        self.isLoggedToday = isLoggedToday
        self.formattedLastReflectionDate = formattedLastReflectionDate
        self.progressPercentage = progressPercentage
        self.progressValue = progressValue
        self.hasAnyReflections = hasAnyReflections
        self.lastReflectionMoodEmoji = lastReflectionMoodEmoji
    }
    
    init(goal: Goal, lastReflection: DailyReflection?, weeklyProgress: Double, dateFormatter: DateFormatter, percentageFormatter: NumberFormatter) {
        self.progressValue = weeklyProgress
        self.progressPercentage = percentageFormatter.string(from: NSNumber(value: weeklyProgress)) ?? "0%"
        
        if let lastReflection = lastReflection {
            self.hasAnyReflections = true
            self.isLoggedToday = Calendar.current.isDateInToday(lastReflection.date)
            self.formattedLastReflectionDate = dateFormatter.string(from: lastReflection.date)
            self.lastReflectionMoodEmoji = lastReflection.mood?.emoji
        } else {
            self.hasAnyReflections = false
            self.isLoggedToday = false
            self.formattedLastReflectionDate = nil
            self.lastReflectionMoodEmoji = nil
        }
    }
    
    static let empty = GoalDisplayStatus(
        isLoggedToday: false,
        formattedLastReflectionDate: nil,
        progressPercentage: "0%",
        progressValue: 0.0,
        hasAnyReflections: false,
        lastReflectionMoodEmoji: nil
    )
} 