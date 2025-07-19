import Foundation
import SwiftUI

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
        print("🔄 IntentionDraftViewModel: updateTitle called with: '\(title)'")
        objectWillChange.send()
        draft.title = title
        print("✅ IntentionDraftViewModel: title updated to: '\(draft.title)'")
    }
    
    func updateReminderTime(_ time: Date?) {
        print("🔄 IntentionDraftViewModel: updateReminderTime called with: \(time?.description ?? "nil")")
        objectWillChange.send()
        draft.reminderTime = time
        print("✅ IntentionDraftViewModel: reminderTime updated to: \(draft.reminderTime?.description ?? "nil")")
    }
    
    func updateRepeatPattern(_ pattern: RepeatPattern) {
        print("🔄 IntentionDraftViewModel: updateRepeatPattern called with: \(pattern.rawValue)")
        objectWillChange.send()
        draft.repeatPattern = pattern
        print("✅ IntentionDraftViewModel: repeatPattern updated to: \(draft.repeatPattern.rawValue)")
    }
    
    func toggleTrackingOption(_ option: GoalOption) {
        print("🔄 IntentionDraftViewModel: toggleTrackingOption called with: \(option.rawValue)")
        print("📊 Current selectedOptions before toggle: \(draft.selectedOptions.map { $0.rawValue })")
        
        objectWillChange.send()
        var newOptions = draft.selectedOptions
        if newOptions.contains(option) {
            print("➖ Removing option: \(option.rawValue)")
            newOptions.remove(option)
        } else {
            print("➕ Adding option: \(option.rawValue)")
            newOptions.insert(option)
        }
        
        draft.selectedOptions = newOptions
        print("✅ IntentionDraftViewModel: selectedOptions updated to: \(draft.selectedOptions.map { $0.rawValue })")
        print("📊 Total options count: \(draft.selectedOptions.count)")
    }
    
    func updateImageName(_ imageName: String?) {
        print("🔄 IntentionDraftViewModel: updateImageName called with: '\(imageName ?? "nil")'")
        print("🖼️ Current imageName before update: '\(draft.imageName ?? "nil")'")
        objectWillChange.send()
        draft.imageName = imageName
        print("✅ IntentionDraftViewModel: imageName updated to: '\(draft.imageName ?? "nil")'")
    }
    
    func handleChatMessage(_ text: String) {
        // 1. Add user message
        chatMessages.append(.user(text))
        
        // 2. Show processing state
        isProcessingMessage = true
        
        // 3. Parse the message after a brief delay (simulate processing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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