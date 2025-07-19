import SwiftUI

struct IntentionsListView: View {
    @ObservedObject var dataStore: DataStore
    @State private var showingAddIntention = false
    @State private var selectedGoal: Goal?
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(dataStore.goals) { goal in
                        let isInEditMode = editMode?.wrappedValue.isEditing == true
                        IntentionCardView(
                            goal: goal, 
                            dataStore: dataStore,
                            isEditMode: isInEditMode,
                            onTap: {
                                selectedGoal = goal
                            }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onMove { source, destination in
                        dataStore.reorderGoals(from: source, to: destination)
                    }
                }
                .listStyle(PlainListStyle())
                
                Button(action: { 
                    showingAddIntention = true 
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Intention")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                }
                .padding()
                .sheet(isPresented: $showingAddIntention) {
                    CreateIntentionScreen(dataStore: dataStore)
                }
            }
            .navigationTitle("Your Intentions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                EditButton()
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedGoal != nil },
                set: { newValue in
                    if !newValue { 
                        selectedGoal = nil 
                    }
                }
            )) {
                if let goal = selectedGoal {
                    ReflectionsListView(goal: goal, dataStore: dataStore)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct IntentionCardView: View {
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    let isEditMode: Bool
    let onTap: () -> Void
    
    // Menu action states
    @State private var showingEditSheet = false
    @State private var showingReminderSheet = false
    @State private var showingInsightsSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingArchiveAlert = false
    @State private var showingDuplicateAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Header Row
            HStack {
                Text(goal.selectedOptions.first?.emoji ?? "🎯")
                    .font(.system(size: 36))
                Text(goal.intention)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Menu {
                    // Primary Actions
                    Button(action: { 
                        showingEditSheet = true 
                    }) {
                        Label("Edit Intention", systemImage: "pencil")
                    }
                    
                    Button(action: { 
                        showingReminderSheet = true 
                    }) {
                        Label("Add/Edit Reminder", systemImage: "bell")
                    }
                    
                    Divider()
                    
                    // Secondary Actions
                    Button(action: { 
                        showingInsightsSheet = true 
                    }) {
                        Label("View Insights", systemImage: "chart.bar")
                    }
                    
                    Button(action: { 
                        showingArchiveAlert = true 
                    }) {
                        Label("Archive Intention", systemImage: "archivebox")
                    }
                    
                    Button(action: { 
                        showingDuplicateAlert = true 
                    }) {
                        Label("Duplicate Intention", systemImage: "plus.square.on.square")
                    }
                    
                    Divider()
                    
                    // Danger Actions
                    Button(action: { 
                        showingDeleteAlert = true 
                    }) {
                        Label("Delete Intention", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
            
            // 2. Image/Gradient Block
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 120)
                if let imageName = goal.imageName {
                    if let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(16)
                            .opacity(0.7)
                            .allowsHitTesting(false)
                    } else {
                        // Fallback to system image if asset not found
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .opacity(0.3)
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .opacity(0.3)
                }
            }
            
            // 3. Progress Bar + Streak
            HStack(spacing: 12) {
                ProgressView(value: progress)
                    .frame(width: 120)
                if goal.streakCount > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(goal.streakCount)-day streak!")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // 4. Last Reflection Info
            HStack(spacing: 8) {
                if let last = lastReflection {
                    Text("Last log: \(last.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                    if let mood = last.mood {
                        Text(mood.emoji)
                    }
                } else {
                    Text("No logs yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 5. Action Row
            HStack {
                Button(action: {
                    onTap()
                }) {
                    Text(loggedToday ? "Logged Today" : "Log Today")
                        .font(.subheadline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(loggedToday ? Color.gray.opacity(0.2) : Color.blue)
                        .foregroundColor(loggedToday ? .gray : .white)
                        .cornerRadius(20)
                        .shadow(radius: loggedToday ? 0 : 2)
                }
                .disabled(loggedToday)
                
                Spacer()
                Button(action: {
                    onTap()
                }) {
                    Text("See All Reflections")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            // Only handle tap when not in edit mode to avoid interfering with drag
            if !isEditMode {
                onTap()
            }
        }
        // Add sheets and alerts
        .sheet(isPresented: $showingEditSheet) {
            EditIntentionView(goal: goal, dataStore: dataStore)
        }
        .sheet(isPresented: $showingReminderSheet) {
            ReminderSettingsView(goal: goal, dataStore: dataStore)
        }
        .sheet(isPresented: $showingInsightsSheet) {
            InsightsView(goal: goal, dataStore: dataStore)
        }
        .alert("Delete Intention", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataStore.deleteGoal(goal)
            }
        } message: {
            Text("This will permanently delete this intention and all associated reflections. This action cannot be undone.")
        }
        .alert("Archive Intention", isPresented: $showingArchiveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Archive", role: .destructive) {
                dataStore.archiveGoal(goal)
            }
        } message: {
            Text("This will hide this intention from your dashboard. You can unarchive it later from the archived section.")
        }
        .alert("Duplicate Intention", isPresented: $showingDuplicateAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Duplicate") {
                dataStore.duplicateGoal(goal)
            }
        } message: {
            Text("This will create a copy of this intention with all its settings. You can then modify it as needed.")
        }
    }
    
    // MARK: - Helpers
    var lastReflection: DailyReflection? {
        dataStore.getReflectionsForGoal(goal.id).first
    }
    var loggedToday: Bool {
        if let last = lastReflection {
            return Calendar.current.isDateInToday(last.date)
        }
        return false
    }
    var progress: Double {
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let weekReflections = dataStore.getReflectionsForGoal(goal.id).filter { $0.date >= weekStart }
        return Double(weekReflections.count) / 5.0
    }
}

struct EditIntentionView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    @StateObject private var draftViewModel: IntentionDraftViewModel
    @State private var isChatVisible = false
    
    init(goal: Goal, dataStore: DataStore) {
        self.goal = goal
        self.dataStore = dataStore
        
        // Initialize the draft view model with existing goal data
        let initialDraft = IntentionDraft(
            title: goal.intention,
            reminderTime: goal.reminderTime,
            repeatPattern: .daily, // Default for now
            durationInMinutes: nil,
            checkInPrompt: nil,
            selectedOptions: goal.selectedOptions,
            imageName: goal.imageName
        )
        
        _draftViewModel = StateObject(wrappedValue: IntentionDraftViewModel(initialDraft: initialDraft))
    }
    
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
            .navigationTitle("Edit Intention")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Create updated goal using the draft
                        let updatedGoal = draftViewModel.createGoal(from: goal)
                        dataStore.updateGoal(updatedGoal)
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
            Image(systemName: "pencil.circle")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Edit Your Intention")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Update your intention using the form below or chat with our AI assistant")
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

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    @State private var isReminderEnabled: Bool
    @State private var reminderTime: Date
    
    init(goal: Goal, dataStore: DataStore) {
        self.goal = goal
        self.dataStore = dataStore
        _isReminderEnabled = State(initialValue: goal.reminderTime != nil)
        _reminderTime = State(initialValue: goal.reminderTime ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Daily Reminder", isOn: $isReminderEnabled)
                    if isReminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedGoal = goal
                        updatedGoal.reminderTime = isReminderEnabled ? reminderTime : nil
                        dataStore.updateGoal(updatedGoal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
        }
    }
}

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("This Week")) {
                    HStack {
                        Text("Reflection Rate")
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .foregroundColor(.secondary)
                    }
                    if goal.streakCount > 0 {
                        HStack {
                            Text("Current Streak")
                            Spacer()
                            Text("\(goal.streakCount) days")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("All Time")) {
                    HStack {
                        Text("Total Reflections")
                        Spacer()
                        Text("\(dataStore.getReflectionsForGoal(goal.id).count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private var progress: Double {
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let weekReflections = dataStore.getReflectionsForGoal(goal.id).filter { $0.date >= weekStart }
        return Double(weekReflections.count) / 5.0
    }
} 
