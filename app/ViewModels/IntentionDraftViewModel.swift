import Foundation
import SwiftUI

/// IntentionDraftViewModel with optimized view updates
/// PERFORMANCE OPTIMIZATION: Removed manual objectWillChange.send() calls
/// @Published properties automatically trigger UI updates when changed
class IntentionDraftViewModel: ObservableObject {
    @Published var draft: IntentionDraft = IntentionDraft()
    @Published var chatMessages: [ChatMessage] = []
    @Published var isProcessingMessage = false
    
    init() {
        // Add welcome message
        chatMessages.append(.bot("Hi! I'm here to help you create your intention. You can tell me things like 'I want to meditate daily at 7 AM' or 'Remind me to read for 30 minutes every night'."))
    }
    
    init(initialDraft: IntentionDraft) {
        self.draft = initialDraft
        // Add welcome message for editing
        chatMessages.append(.bot("Hi! I'm here to help you update your intention. You can tell me things like 'Change the time to 8 AM' or 'Add journaling as a tracking option'."))
    }
    
    // MARK: - Draft Update Methods
    func updateTitle(_ title: String) {
        draft.title = title
    }
    
    func updateReminderTime(_ time: Date?) {
        draft.reminderTime = time
    }
    
    func updateRepeatPattern(_ pattern: RepeatPattern) {
        draft.repeatPattern = pattern
    }
    
    func toggleTrackingOption(_ option: GoalOption) {
        var newOptions = draft.selectedOptions
        if newOptions.contains(option) {
            newOptions.remove(option)
        } else {
            newOptions.insert(option)
        }
        draft.selectedOptions = newOptions
    }
    
    func updateImageName(_ imageName: String?) {
        draft.imageName = imageName
    }
    
    func handleChatMessage(_ text: String) {
        // 1. Add user message
        chatMessages.append(.user(text))
        
        // 2. Show processing state
        isProcessingMessage = true
        
        // 3. Parse the message after a brief delay (simulate processing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.processMessage(text)
            self.isProcessingMessage = false
        }
    }
    
    private func processMessage(_ text: String) {
        // Parse input into structured updates
        let updates = ChatIntentParser.parse(text)
        
        // Apply updates to draft
        apply(updates)
        
        // Generate response message
        let responseMessage = generateResponse(for: updates, originalText: text)
        chatMessages.append(.bot(responseMessage))
    }
    
    private func apply(_ updates: IntentUpdates) {
        if let title = updates.title {
            draft.title = title
        }
        
        if let reminderTime = updates.reminderTime {
            draft.reminderTime = reminderTime
        }
        
        if let repeatPattern = updates.repeatPattern {
            draft.repeatPattern = repeatPattern
        }
        
        if let duration = updates.durationInMinutes {
            draft.durationInMinutes = duration
        }
        
        if let checkInPrompt = updates.checkInPrompt {
            draft.checkInPrompt = checkInPrompt
        }
        
        if let selectedOptions = updates.selectedOptions {
            draft.selectedOptions = selectedOptions
        }
    }
    
    private func generateResponse(for updates: IntentUpdates, originalText: String) -> String {
        if updates.summary.isEmpty {
            return "I understand you want to work on '\(originalText)'. Could you be more specific? For example, try saying 'I want to meditate daily at 7 AM' or 'Remind me to exercise 3 times a week'."
        }
        
        var responses: [String] = []
        
        if let title = updates.title {
            responses.append("✨ Set your intention to: \(title)")
        }
        
        if let _ = updates.reminderTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            if let time = draft.reminderTime {
                responses.append("⏰ Added reminder at \(formatter.string(from: time))")
            }
        }
        
        if let pattern = updates.repeatPattern {
            responses.append("🔄 Set frequency to: \(pattern.description)")
        }
        
        if let duration = updates.durationInMinutes {
            responses.append("⏱️ Set duration to: \(duration) minutes")
        }
        
        if let options = updates.selectedOptions {
            let optionNames = options.map { $0.rawValue }.joined(separator: ", ")
            responses.append("📊 Added tracking: \(optionNames)")
        }
        
        if responses.isEmpty {
            return "Got it! I've noted that down. Feel free to add more details or adjust anything in the form below."
        }
        
        return responses.joined(separator: "\n") + "\n\nAnything else you'd like to adjust?"
    }
    
    func resetDraft() {
        draft = IntentionDraft()
        chatMessages = [.bot("Hi! I'm here to help you create your intention. You can tell me things like 'I want to meditate daily at 7 AM' or 'Remind me to read for 30 minutes every night'.")]
    }
    
    func createGoal() -> Goal {
        return Goal(
            intention: draft.title.isEmpty ? "My Intention" : draft.title,
            selectedOptions: draft.selectedOptions,
            reminderTime: draft.reminderTime,
            imageName: draft.imageName
        )
    }
    
    func createGoal(from existingGoal: Goal) -> Goal {
        var updatedGoal = existingGoal
        updatedGoal.intention = draft.title.isEmpty ? existingGoal.intention : draft.title
        updatedGoal.selectedOptions = draft.selectedOptions
        updatedGoal.reminderTime = draft.reminderTime
        updatedGoal.imageName = draft.imageName ?? existingGoal.imageName
        return updatedGoal
    }
} 