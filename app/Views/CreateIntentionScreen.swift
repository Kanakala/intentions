import SwiftUI

struct CreateIntentionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataStore: DataStore
    @StateObject private var draftViewModel = IntentionDraftViewModel()
    @State private var isChatVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Form
                        IntentionFormView(draftViewModel: draftViewModel)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Floating Chat Bubble
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingChatBubbleButton(isVisible: $isChatVisible)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
                
                // Chat Assistant Balloon
                if isChatVisible {
                    ChatAssistantBalloonView(
                        isVisible: $isChatVisible,
                        draftViewModel: draftViewModel
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .navigationTitle("Create Intention")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = draftViewModel.createGoal()
                        dataStore.saveGoal(goal)
                        dismiss()
                    }
                    .disabled(draftViewModel.draft.title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        // Remove the problematic global onTapGesture
        .background(
            // Better chat dismissal - only on background areas
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if isChatVisible {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isChatVisible = false
                        }
                    }
                }
                .allowsHitTesting(isChatVisible) // Only active when chat is visible
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Create Your Intention")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Fill out the form below or chat with our AI assistant to get started quickly")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct FloatingChatBubbleButton: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: isVisible ? "xmark" : "message.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isVisible ? 180 : 0))
            }
        }
        .scaleEffect(isVisible ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

#Preview {
    CreateIntentionScreen(dataStore: DataStore())
} 