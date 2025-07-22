import SwiftUI

struct DailyReflectionView: View {
    @StateObject private var viewModel: DailyReflectionViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataStore: DataStore
    let onDismiss: () -> Void
    
    init(goal: Goal, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DailyReflectionViewModel(goal: goal))
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Daily Actions Section
                    dailyActionsSection
                    
                    // Motivational Message
                    motivationalMessage
                    
                    // Submit Button
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                loadingOverlay
            }
            
            // Success Animation
            if viewModel.showSuccessAnimation {
                successAnimation
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Text("Today's Reflection")
                .font(.title)
                .fontWeight(.bold)
            
            if let goal = viewModel.currentGoal {
                Text(goal.intention)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var dailyActionsSection: some View {
        VStack(spacing: 16) {
            if let goal = viewModel.currentGoal {
                ForEach(goal.dailyActions) { action in
                    DailyActionView(
                        action: action,
                        response: Binding(
                            get: { viewModel.actionResponses[action.id] ?? "" },
                            set: { newValue in
                                viewModel.actionResponses[action.id] = newValue
                                viewModel.submitResponse(for: action, value: newValue)
                            }
                        )
                    )
                }
            } else {
                Text("No goal available")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var motivationalMessage: some View {
        Text("Small steps matter. You're rewiring your habits, not forcing them.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var submitButton: some View {
        Button(action: {
            guard viewModel.isReflectionComplete() else {
                return
            }
            viewModel.submitReflection { reflection in
                // Save the reflection first
                dataStore.saveReflection(reflection)
                
                // Show success animation
                withAnimation {
                    viewModel.showSuccessAnimation = true
                }
                
                // Dismiss after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak viewModel] in
                    guard let viewModel = viewModel else { return }
                    withAnimation {
                        viewModel.showSuccessAnimation = false
                        onDismiss()
                    }
                }
            }
        }) {
            Text("Complete Reflection")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isReflectionComplete() ? Color.blue : Color.gray)
                .cornerRadius(18)
                .shadow(radius: viewModel.isReflectionComplete() ? 4 : 0)
        }
        .disabled(viewModel.isLoading || !viewModel.isReflectionComplete())
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Saving your reflection...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
    }
    
    private var successAnimation: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                if let message = viewModel.streakMessage {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct DailyActionView: View {
    let action: DailyAction
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(action.prompt)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            switch action.type {
            case .scale:
                ScaleInputView(value: $response, range: action.configuration.range ?? 1...10) { value in
                    response = value
                }
            case .text:
                TextInputView(text: $response, maxLength: action.configuration.maxLength, placeholder: action.configuration.placeholder ?? "") { value in
                    response = value
                }
            case .number:
                NumberInputView(value: $response, unit: action.configuration.unit ?? "") { value in
                    response = value
                }
            case .check:
                CheckInputView(isChecked: Binding(
                    get: { response == "true" },
                    set: { newValue in
                        response = newValue ? "true" : "false"
                    }
                ))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct ScaleInputView: View {
    @Binding var value: String
    let range: ClosedRange<Int>
    let onValueChanged: (String) -> Void
    
    private let moods: [(emoji: String, label: String)] = [
        ("😢", "Very Sad"),
        ("😕", "Sad"),
        ("😐", "Neutral"),
        ("🙂", "Happy"),
        ("😊", "Very Happy")
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(Array(moods.enumerated()), id: \.offset) { index, mood in
                    Button(action: {
                        let newValue = String(index + 1)
                        value = newValue
                        onValueChanged(newValue)
                    }) {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                                .scaleEffect(value == String(index + 1) ? 1.2 : 1.0)
                            
                            Text(mood.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(width: 60, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(value == String(index + 1) ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            if value.isEmpty {
                value = "3"
                onValueChanged("3")
            }
        }
    }
}

struct TextInputView: View {
    @Binding var text: String
    let maxLength: Int?
    let placeholder: String
    let onValueChanged: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .onChange(of: text) { oldValue, newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                    onValueChanged(text)
                }
            
            if let maxLength = maxLength {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct NumberInputView: View {
    @Binding var value: String
    let unit: String
    let onValueChanged: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 120)
                .onChange(of: value) { oldValue, newValue in
                    if let _ = Double(newValue) {
                        onValueChanged(newValue)
                    } else if !newValue.isEmpty {
                        value = ""
                        onValueChanged("")
                    }
                }
            
            if !unit.isEmpty {
                Text(unit)
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

struct CheckInputView: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .blue : .gray)
                    .font(.title2)
                
                Text(isChecked ? "Completed" : "Mark as Complete")
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview Providers
#Preview("Daily Reflection View") {
    let sampleGoal = Goal(
        intention: "I want to reduce my junk food intake",
        selectedOptions: [.dailyReflection, .journalEntry, .celebrateWins]
    )
    return DailyReflectionView(goal: sampleGoal) { }
}

#Preview("Scale Input") {
    ScaleInputView(value: .constant("3"), range: 1...5) { _ in }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
}

#Preview("Text Input") {
    TextInputView(
        text: .constant(""),
        maxLength: 280,
        placeholder: "How did you feel about your choices today?"
    ) { _ in }
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(10)
}

#Preview("Number Input") {
    NumberInputView(value: .constant("75"), unit: "kg") { _ in }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
}

#Preview("Check Input") {
    CheckInputView(isChecked: .constant(false))
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
}

#Preview("Daily Action View - Scale") {
    let action = DailyAction(from: .dailyReflection)
    return DailyActionView(action: action, response: .constant(""))
        .padding()
}

#Preview("Daily Action View - Text") {
    let action = DailyAction(from: .journalEntry)
    return DailyActionView(action: action, response: .constant(""))
        .padding()
}

#Preview("Daily Action View - Number") {
    let action = DailyAction(from: .weeklyCheck)
    return DailyActionView(action: action, response: .constant(""))
        .padding()
}

#Preview("Daily Action View - Check") {
    let action = DailyAction(from: .morningReminder)
    return DailyActionView(action: action, response: .constant(""))
        .padding()
}

#Preview("Loading State") {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text("Today's Reflection")
                .font(.title)
                .fontWeight(.bold)
            
            Text("I want to reduce my junk food intake")
                .font(.headline)
                .foregroundColor(.secondary)
            
            DailyActionView(action: DailyAction(from: .dailyReflection), response: .constant(""))
            
            DailyActionView(action: DailyAction(from: .journalEntry), response: .constant(""))
            
            DailyActionView(action: DailyAction(from: .celebrateWins), response: .constant(""))
            
            Spacer()
        }
        .padding()
        
        // Loading Overlay
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Saving your reflection...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
    }
}

#Preview("Success State") {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text("Today's Reflection")
                .font(.title)
                .fontWeight(.bold)
            
            Text("I want to reduce my junk food intake")
                .font(.headline)
                .foregroundColor(.secondary)
            
            DailyActionView(action: DailyAction(from: .dailyReflection), response: .constant(""))
            
            DailyActionView(action: DailyAction(from: .journalEntry), response: .constant(""))
            
            DailyActionView(action: DailyAction(from: .celebrateWins), response: .constant(""))
            
            Spacer()
        }
        .padding()
        
        // Success Overlay
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Three days strong! You're building momentum! 🌳")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
    }
} 
