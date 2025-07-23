import SwiftUI
import UIKit

/// IntentionsListView with modern design system applied
/// Uses SectionCard, PrimaryButton, and design tokens for consistent styling
struct IntentionsListView: View {
    @ObservedObject var dataStore: DataStore
    @State private var showingAddIntention = false
    @State private var selectedGoal: Goal?
    @State private var filterState = IntentionsFilterState()
    @Environment(\.editMode) private var editMode
    
    // Computed property for filtered goals
    private var displayedGoals: [Goal] {
        dataStore.filteredGoals(with: filterState)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.lg) {
                    // Filter Interface - Wrapped in SectionCard
                    SectionCard(style: .elevated, padding: .all(AppSpacing.md)) {
                        IntentionsFilterView(
                            filterState: $filterState,
                            goalCount: dataStore.goals.filter { !$0.isArchived }.count,
                            filteredCount: displayedGoals.count
                        )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: displayedGoals)
                    
                    // Main Content Area
                    ZStack(alignment: .bottomTrailing) {
                        if displayedGoals.isEmpty {
                            emptyStateView
                        } else {
                            ScrollView {
                                LazyVStack(spacing: AppSpacing.lg) {
                                    ForEach(displayedGoals) { goal in
                                        ModernIntentionCardView(
                                            goal: goal, 
                                            dataStore: dataStore,
                                            isEditMode: editMode?.wrappedValue.isEditing == true,
                                            onTap: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    selectedGoal = goal
                                                }
                                            }
                                        )
                                        .padding(.horizontal, AppSpacing.lg)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: displayedGoals)
                                    }
                                }
                                .padding(.vertical, AppSpacing.md)
                            }
                        }
                        
                        // Modern Floating Action Button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                PrimaryButton(
                                    title: "Add Intention",
                                    action: {
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                        showingAddIntention = true
                                    },
                                    style: .primary,
                                    size: .medium,
                                    icon: "plus"
                                )
                                .floatingShadow()
                            }
                            .padding(AppSpacing.lg)
                        }
                    }
                }
            }
            .navigationTitle("Your Intentions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        withAnimation(.easeInOut(duration: AppSpacing.animationMedium)) {
                            if editMode?.wrappedValue.isEditing == true {
                                editMode?.wrappedValue = .inactive
                            } else {
                                editMode?.wrappedValue = .active
                            }
                        }
                    }
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.primary)
                    .disabled(filterState.sortOption != .manual)
                }
            }
            .sheet(isPresented: $showingAddIntention) {
                CreateIntentionScreen(dataStore: dataStore)
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
        .onAppear {
            dataStore.preloadImages(for: dataStore.goals)
        }
    }
    
    private var emptyStateView: some View {
        SectionCard(style: .subtle, padding: .all(AppSpacing.xxxl)) {
            VStack(spacing: AppSpacing.xl) {
                // Empty state icon
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: filterState.searchText.isEmpty ? "target" : "magnifyingglass")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }
                
                VStack(spacing: AppSpacing.md) {
                    Text(filterState.searchText.isEmpty ? "No intentions found" : "No matching intentions")
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !filterState.searchText.isEmpty {
                        Text("Try adjusting your search or filters")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        PrimaryButton.secondary("Clear Search") {
                            withAnimation(.easeInOut(duration: AppSpacing.animationMedium)) {
                                filterState.searchText = ""
                            }
                        }
                        .frame(maxWidth: 200)
                    } else if filterState.filterOption != .active {
                        Text("Try changing your filter settings")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        PrimaryButton.secondary("Show All Active") {
                            withAnimation(.easeInOut(duration: AppSpacing.animationMedium)) {
                                filterState.filterOption = .active
                            }
                        }
                        .frame(maxWidth: 200)
                    } else {
                        Text("Create your first intention to get started!")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        PrimaryButton.primary("Create Intention") {
                            showingAddIntention = true
                        }
                        .frame(maxWidth: 200)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Intention Card with Design System
struct ModernIntentionCardView: View {
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
    
    // Cached display data for performance
    private var displayStatus: GoalDisplayStatus {
        dataStore.getDisplayStatusForGoal(goal.id)
    }
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        SectionCard(style: .elevated, padding: .all(AppSpacing.lg)) {
            VStack(spacing: AppSpacing.md) {
                // 1. Header Section
                headerSection
                
                // 2. Visual Section (Image/Gradient) - More compact
                visualSection
                
                // 3. Progress & Actions Combined Section
                bottomSection
            }
        }
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            if !isEditMode {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isPressed = false
                    onTap()
                }
            }
        }
        .cardShadow()
        .contextMenu {
            contextMenuItems
        }
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
    
    private var headerSection: some View {
        HStack(spacing: AppSpacing.md) {
            // Emoji
            Text(goal.selectedOptions.first?.emoji ?? "🎯")
                .font(.system(size: 36))
            
            // Title and reminder info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(goal.intention)
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: AppSpacing.sm) {
                    // Status indicator
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: displayStatus.isLoggedToday ? "checkmark.circle.fill" : "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(displayStatus.isLoggedToday ? AppColors.success : AppColors.textTertiary)
                        
                        Text(displayStatus.isLoggedToday ? "Logged today" : "Not logged")
                            .font(AppFonts.captionLarge)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    if let reminderTime = goal.reminderTime {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.primary)
                            
                            Text(reminderTime.formatted(date: .omitted, time: .shortened))
                                .font(AppFonts.captionLarge)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // More Menu
            Menu {
                contextMenuItems
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: AppSpacing.iconMedium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(AppSpacing.sm)
                    .background(
                        Circle()
                            .fill(AppColors.surfaceBackground)
                    )
            }
        }
    }
    
    private var visualSection: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.primary.opacity(0.12),
                            AppColors.primary.opacity(0.20)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 100)
            
            // Image overlay
            if let uiImage = dataStore.getCachedImage(named: goal.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(AppSpacing.cornerRadiusMedium)
                    .opacity(0.85)
            } else {
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "photo")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppColors.primary.opacity(0.7))
                    
                    Text("Visual Goal")
                        .font(AppFonts.captionMedium)
                        .foregroundColor(AppColors.primary.opacity(0.8))
                }
            }
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Progress and streak row
            HStack(spacing: AppSpacing.lg) {
                // Progress info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("Progress")
                            .font(AppFonts.labelMedium)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text(displayStatus.progressPercentage)
                            .font(AppFonts.labelMedium)
                            .foregroundColor(AppColors.primary)
                            .fontWeight(.semibold)
                    }
                    
                    ProgressView(value: displayStatus.progressValue)
                        .tint(AppColors.progressGreen)
                        .background(AppColors.surfaceBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                
                // Streak indicator (compact)
                if goal.streakCount > 0 {
                    HStack(spacing: AppSpacing.xs) {
                        Text("🔥")
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(goal.streakCount)")
                                .font(AppFonts.labelMedium)
                                .foregroundColor(AppColors.streakOrange)
                                .fontWeight(.semibold)
                            
                            Text("streak")
                                .font(AppFonts.captionSmall)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                            .fill(AppColors.streakOrange.opacity(0.1))
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        Button(action: { showingEditSheet = true }) {
            Label("Edit Intention", systemImage: "pencil")
        }
        
        Button(action: { showingReminderSheet = true }) {
            Label("Add/Edit Reminder", systemImage: "bell")
        }
        
        Divider()
        
        Button(action: { showingInsightsSheet = true }) {
            Label("View Insights", systemImage: "chart.bar")
        }
        
        Button(action: { showingArchiveAlert = true }) {
            Label("Archive Intention", systemImage: "archivebox")
        }
        
        Button(action: { showingDuplicateAlert = true }) {
            Label("Duplicate Intention", systemImage: "plus.square.on.square")
        }
        
        Divider()
        
        Button(action: {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            showingDeleteAlert = true
        }) {
            Label("Delete Intention", systemImage: "trash")
                .foregroundColor(.red)
        }
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
    
    // Cached display data for performance
    private var displayStatus: GoalDisplayStatus {
        dataStore.getDisplayStatusForGoal(goal.id)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("This Week")) {
                    HStack {
                        Text("Reflection Rate")
                        Spacer()
                        Text(displayStatus.progressPercentage)
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
                        Text("\(dataStore.getReflectionCountForGoal(goal.id))")
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
} 
