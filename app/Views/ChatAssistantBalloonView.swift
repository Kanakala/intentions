import SwiftUI

struct ChatAssistantBalloonView: View {
    @Binding var isVisible: Bool
    @ObservedObject var draftViewModel: IntentionDraftViewModel
    @State private var messageText = ""
    @GestureState private var dragOffset: CGFloat = 0
    @State private var hasDismissed = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Chat Balloon
                VStack(spacing: 0) {
                    // Handle bar
                    handleBar
                    
                    // Chat content
                    chatContent
                    
                    // Input area
                    inputArea
                }
                .frame(height: geometry.size.height * 0.6)
                .background(Color(.systemBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.height > 0 {
                                state = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 80 && isVisible && !hasDismissed {
                                hasDismissed = true
                                print("[ChatBalloon] Drag gesture triggered close")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isVisible = false
                                }
                            }
                        }
                )
            }
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    if !hasDismissed {
                        hasDismissed = true
                        print("[ChatBalloon] Background tap triggered close")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }
        )
        .onAppear { hasDismissed = false }
    }
    
    private var handleBar: some View {
        VStack(spacing: 12) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 8)
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Assistant")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Tell me about your intention in natural language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if !hasDismissed {
                        hasDismissed = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
        }
    }
    
    private var chatContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(draftViewModel.chatMessages) { message in
                        ChatBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if draftViewModel.isProcessingMessage {
                        TypingIndicatorView()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: draftViewModel.chatMessages.count) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak draftViewModel] in
                    guard let draftViewModel = draftViewModel else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let lastMessage = draftViewModel.chatMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onChange(of: draftViewModel.isProcessingMessage) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak draftViewModel] in
                    guard let draftViewModel = draftViewModel else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if draftViewModel.isProcessingMessage {
                            proxy.scrollTo("typing", anchor: .bottom)
                        } else if let lastMessage = draftViewModel.chatMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type your intention here...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draftViewModel.isProcessingMessage)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        draftViewModel.handleChatMessage(trimmedMessage)
        messageText = ""
        
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userBubble
            } else {
                assistantBubble
                Spacer()
            }
        }
    }
    
    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                .frame(maxWidth: 250, alignment: .trailing)
            
            Text(timeString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var assistantBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                    .frame(maxWidth: 250, alignment: .leading)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                )
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
            
            Spacer()
        }
        .onAppear {
            animationOffset = -3
        }
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatAssistantBalloonView(
        isVisible: .constant(true),
        draftViewModel: IntentionDraftViewModel()
    )
} 