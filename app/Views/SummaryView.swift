import SwiftUI

struct SummaryView: View {
    let intention: String
    let selectedOptions: Set<GoalOption>
    @Binding var currentStep: Int
    let onComplete: (Goal) -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Button(action: {
                    withAnimation {
                        currentStep = 1
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
            
            Text("Your Journey Begins")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your Intention")
                .font(.headline)
            
            Text(intention)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            Text("Your Support System")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Array(selectedOptions)) { option in
                        HStack {
                            Text(option.emoji)
                                .font(.title2)
                            Text(option.description)
                                .font(.body)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                let goal = Goal(intention: intention, selectedOptions: selectedOptions)
                onComplete(goal)
            }) {
                Text("Start Your Journey")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
} 