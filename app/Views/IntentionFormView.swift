import SwiftUI

struct IntentionFormView: View {
    @ObservedObject var draftViewModel: IntentionDraftViewModel
    
    let availableImages = [
        "run1.png", "run2.png", "run3.png", "read.png", "meditation.png",
        "image1.jpeg", "image2.jpeg", "image3.jpeg", "image4.jpeg"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Title Section
            titleSection
            
            // Reminder Section
            reminderSection
            
            // Frequency Section
            frequencySection
            
            // Tracking Options Section
            trackingOptionsSection
            
            // Image Selection Section
            imageSelectionSection
        }
        .onAppear {
            print("📋 Form appeared with: \(draftViewModel.draft.selectedOptions.map { $0.rawValue })")
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Intention Title")
                    .font(.headline)
                if !draftViewModel.draft.title.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            TextField("e.g., Meditate daily, Read before bed...", text: Binding(
                get: { draftViewModel.draft.title },
                set: { draftViewModel.updateTitle($0) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reminder Time")
                    .font(.headline)
                if draftViewModel.draft.reminderTime != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Toggle("Enable Reminder", isOn: Binding(
                get: { draftViewModel.draft.reminderTime != nil },
                set: { enabled in
                    if enabled {
                        let defaultTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
                        draftViewModel.updateReminderTime(defaultTime)
                    } else {
                        draftViewModel.updateReminderTime(nil)
                    }
                }
            ))
            
            if draftViewModel.draft.reminderTime != nil {
                DatePicker(
                    "Time",
                    selection: Binding(
                        get: { draftViewModel.draft.reminderTime ?? Date() },
                        set: { draftViewModel.updateReminderTime($0) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Frequency")
                    .font(.headline)
                if draftViewModel.draft.repeatPattern != .none {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Picker("Frequency", selection: Binding(
                get: { draftViewModel.draft.repeatPattern },
                set: { draftViewModel.updateRepeatPattern($0) }
            )) {
                ForEach(RepeatPattern.allCases) { pattern in
                    Text(pattern.description).tag(pattern)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var trackingOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tracking Options")
                    .font(.headline)
                Text("(\(draftViewModel.draft.selectedOptions.count) selected)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Simple vertical layout
            VStack(spacing: 12) {
                ForEach(GoalOption.allCases, id: \.self) { option in
                    OptionToggleCard(
                        option: option,
                        draftViewModel: draftViewModel
                    ) {
                        print("🎯 Form: Tapped \(option.rawValue)")
                        draftViewModel.toggleTrackingOption(option)
                        print("🎯 Form: Completed \(option.rawValue)")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var imageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Card Image")
                    .font(.headline)
                if draftViewModel.draft.imageName != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableImages, id: \.self) { imageName in
                        ImageSelectionCard(
                            imageName: imageName,
                            draftViewModel: draftViewModel
                        ) {
                            print("🖼️ IntentionFormView: ImageSelectionCard tapped for: \(imageName)")
                            print("🖼️ Current selection state before tap: \(draftViewModel.draft.imageName == imageName)")
                            print("🖼️ Current imageName: '\(draftViewModel.draft.imageName ?? "nil")'")
                            draftViewModel.updateImageName(imageName)
                            print("🖼️ Current selection state after tap: \(draftViewModel.draft.imageName == imageName)")
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct OptionToggleCard: View {
    let option: GoalOption
    @ObservedObject var draftViewModel: IntentionDraftViewModel
    let action: () -> Void
    
    @State private var isSelected: Bool = false
    @State private var isPressed: Bool = false
    
    var body: some View {
        // Main card content
        HStack(spacing: 12) {
            Text(option.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(option.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(option.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundView)
        .contentShape(Rectangle())
        .onTapGesture {
            print("🟢 PRIMARY TAP: \(option.rawValue)")
            handleTap()
        }
        .highPriorityGesture(
            TapGesture().onEnded { _ in
                print("🔥 HIGH PRIORITY TAP: \(option.rawValue)")
                handleTap()
            }
        )
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                print("🟡 SIMULTANEOUS TAP: \(option.rawValue)")
            }
        )
        .allowsHitTesting(true)
        .clipped()
        .onAppear {
            setupInitialState()
        }
        .onReceive(draftViewModel.objectWillChange) { _ in
            updateStateOptimized()
        }
    }
    
    // Separate background view to reduce complexity
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    // Optimized tap handler
    private func handleTap() {
        print("🟢 EXECUTING: \(option.rawValue)")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        action()
        print("🟢 COMPLETED: \(option.rawValue)")
    }
    
    // Optimized setup
    private func setupInitialState() {
        let currentSelection = draftViewModel.draft.selectedOptions.contains(option)
        print("🔵 SETUP: \(option.rawValue) = \(currentSelection)")
        isSelected = currentSelection
    }
    
    // Optimized state update
    private func updateStateOptimized() {
        let newIsSelected = draftViewModel.draft.selectedOptions.contains(option)
        if newIsSelected != isSelected {
            print("🔄 UPDATE: \(option.rawValue) -> \(newIsSelected)")
            isSelected = newIsSelected
        }
    }
}

struct ImageSelectionCard: View {
    let imageName: String
    @ObservedObject var draftViewModel: IntentionDraftViewModel
    let action: () -> Void
    
    @State private var isSelected: Bool = false
    @State private var isPressed: Bool = false // Add press state for visual feedback
    
    var body: some View {
        ZStack {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 60)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 60)
                    .overlay(
                        Text("?")
                            .foregroundColor(.gray)
                    )
            }
            
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(4)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0) // Add press animation
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .contentShape(Rectangle()) // Ensure entire area is tappable
        .onTapGesture {
            print("🖼️ ImageSelectionCard: TAP GESTURE triggered for \(imageName)")
            print("🖼️ ImageSelectionCard: Current isSelected state: \(isSelected)")
            print("🖼️ ImageSelectionCard: Current draft imageName: '\(draftViewModel.draft.imageName ?? "nil")'")
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Visual feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            
            action()
            print("🖼️ ImageSelectionCard: Action completed for \(imageName)")
        }
        .onAppear {
            let currentSelection = draftViewModel.draft.imageName == imageName
            print("🖼️ ImageSelectionCard: Appeared for \(imageName) with isSelected: \(currentSelection)")
            print("🖼️ ImageSelectionCard: Current draft imageName: '\(draftViewModel.draft.imageName ?? "nil")'")
            isSelected = currentSelection
        }
        .onReceive(draftViewModel.objectWillChange) { _ in
            DispatchQueue.main.async {
                let newIsSelected = draftViewModel.draft.imageName == imageName
                if newIsSelected != isSelected {
                    print("🖼️ ImageSelectionCard: Selection changed for \(imageName) from \(isSelected) to \(newIsSelected)")
                    print("🖼️ ImageSelectionCard: Updated draft imageName: '\(draftViewModel.draft.imageName ?? "nil")'")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSelected = newIsSelected
                    }
                }
            }
        }
    }
}

#Preview {
    IntentionFormView(draftViewModel: IntentionDraftViewModel())
        .padding()
        .background(Color(.systemGroupedBackground))
} 