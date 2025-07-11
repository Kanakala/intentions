import SwiftUI

struct IntentionView: View {
    @Binding var intention: String
    @Binding var currentStep: Int
    @State private var showLoading = false
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Define Your Intention")
                .font(.title)
                .fontWeight(.bold)
            
            Text("What's something you wish to change, grow, or become?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            TextField("I want to reduce my junk food intake...", text: $intention)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if showLoading {
                LoadingView()
                    .transition(.opacity)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showLoading = true
                }
                
                // Delay the transition to OptionsView
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        currentStep = 1
                    }
                }
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(intention.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(intention.isEmpty || showLoading)
        }
        .padding()
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.blue, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("That's powerful. Let's shape how this journey supports you.")
                .font(.headline)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .transition(.opacity)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
