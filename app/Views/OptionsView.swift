import SwiftUI

struct OptionsView: View {
    @Binding var selectedOptions: Set<GoalOption>
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Button(action: {
                    withAnimation {
                        currentStep = 0
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Define your journey")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Which of these would help you stay connected to your goal?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(GoalOption.allCases) { option in
                        OptionToggle(option: option, isSelected: selectedOptions.contains(option)) {
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                withAnimation {
                    currentStep = 2
                }
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOptions.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(selectedOptions.isEmpty)
        }
        .padding()
    }
}

struct OptionToggle: View {
    let option: GoalOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.emoji)
                    .font(.title2)
                Text(option.description)
                    .font(.body)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
        }
    }
} 
