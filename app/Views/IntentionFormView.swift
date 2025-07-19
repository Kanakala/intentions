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
                        draftViewModel.toggleTrackingOption(option)
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
                            draftViewModel.updateImageName(imageName)
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
    
    var body: some View {
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
        .highPriorityGesture(
            TapGesture().onEnded { _ in
                handleTap()
            }
        )
        .onAppear {
            setupInitialState()
        }
        .onReceive(draftViewModel.objectWillChange) { _ in
            updateState()
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    private func handleTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        action()
    }
    
    private func setupInitialState() {
        isSelected = draftViewModel.draft.selectedOptions.contains(option)
    }
    
    private func updateState() {
        let newIsSelected = draftViewModel.draft.selectedOptions.contains(option)
        if newIsSelected != isSelected {
            isSelected = newIsSelected
        }
    }
}

struct ImageSelectionCard: View {
    let imageName: String
    @ObservedObject var draftViewModel: IntentionDraftViewModel
    let action: () -> Void
    
    @State private var isSelected: Bool = false
    
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
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture().onEnded { _ in
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        )
        .onAppear {
            isSelected = draftViewModel.draft.imageName == imageName
        }
        .onReceive(draftViewModel.objectWillChange) { _ in
            DispatchQueue.main.async {
                let newIsSelected = draftViewModel.draft.imageName == imageName
                if newIsSelected != isSelected {
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