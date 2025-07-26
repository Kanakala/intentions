import SwiftUI

enum Tab: Int {
    case home, progress, add, logs, settings
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var isPresentingAddIntention = false
    @State private var isChatVisible = false
    @FocusState private var isSearchFocused: Bool
    @ObservedObject var dataStore: DataStore

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                IntentionsListView(dataStore: dataStore, isChatVisible: $isChatVisible, isSearchFocused: $isSearchFocused)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(Tab.home)

                InsightsView(goal: dataStore.goals.first ?? Goal(intention: "Sample Intention", selectedOptions: [], reminderTime: nil, isArchived: false, imageName: nil, order: 0), dataStore: dataStore)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Progress")
                    }
                    .tag(Tab.progress)

                DailyLogView()
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Logs")
                    }
                    .tag(Tab.logs)

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(Tab.settings)
            }
            .accentColor(AppColors.primary)

            // Center-docked floating + button
            if !isChatVisible && !isSearchFocused {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresentingAddIntention.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(AppColors.primary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
                        }
                        .offset(y: -24)
                        Spacer()
                    }
                }
            }

            // Custom overlay for chat balloon
            if isChatVisible {
                ChatBalloonOverlay(isVisible: $isChatVisible)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .sheet(isPresented: $isPresentingAddIntention) {
            CreateIntentionScreen(dataStore: dataStore)
                .transition(.move(edge: .bottom))
        }
    }
}

struct ChatBalloonOverlay: View {
    @Binding var isVisible: Bool
    @StateObject private var globalChatViewModel = IntentionDraftViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            VStack {
                Spacer()
                ChatAssistantBalloonView(
                    isVisible: $isVisible,
                    draftViewModel: globalChatViewModel
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
} 