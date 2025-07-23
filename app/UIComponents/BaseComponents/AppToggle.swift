import SwiftUI

/// Modern toggle/switch component with consistent styling
/// Supports different sizes, styles, and labels
struct AppToggle: View {
    @Binding var isOn: Bool
    var size: ToggleSize = .medium
    var style: ToggleStyle = .standard
    var isEnabled: Bool = true
    var animation: Animation = .easeInOut(duration: 0.2)
    
    var body: some View {
        Button(action: {
            if isEnabled {
                withAnimation(animation) {
                    isOn.toggle()
                }
            }
        }) {
            ZStack {
                // Background Track
                RoundedRectangle(cornerRadius: size.trackCornerRadius)
                    .fill(trackColor)
                    .frame(width: size.trackWidth, height: size.trackHeight)
                
                // Thumb
                HStack {
                    if isOn {
                        Spacer()
                    }
                    
                    Circle()
                        .fill(thumbColor)
                        .frame(width: size.thumbSize, height: size.thumbSize)
                        .shadow(
                            color: AppColors.shadowMedium,
                            radius: size.thumbShadowRadius,
                            x: 0,
                            y: 1
                        )
                    
                    if !isOn {
                        Spacer()
                    }
                }
                .padding(size.thumbPadding)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: AppSpacing.animationFast), value: isEnabled)
    }
    
    // MARK: - Computed Properties
    private var trackColor: Color {
        if isOn {
            switch style {
            case .standard:
                return AppColors.primary
            case .success:
                return AppColors.success
            case .warning:
                return AppColors.warning
            case .error:
                return AppColors.error
            }
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var thumbColor: Color {
        return AppColors.cardBackground
    }
}

// MARK: - Toggle Sizes
extension AppToggle {
    enum ToggleSize {
        case small
        case medium
        case large
        
        var trackWidth: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 52
            case .large: return 60
            }
        }
        
        var trackHeight: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 28
            case .large: return 32
            }
        }
        
        var trackCornerRadius: CGFloat {
            return trackHeight / 2
        }
        
        var thumbSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 28
            }
        }
        
        var thumbPadding: CGFloat {
            return (trackHeight - thumbSize) / 2
        }
        
        var thumbShadowRadius: CGFloat {
            switch self {
            case .small: return 1
            case .medium: return 2
            case .large: return 3
            }
        }
    }
}

// MARK: - Toggle Styles
extension AppToggle {
    enum ToggleStyle {
        case standard
        case success
        case warning
        case error
    }
}

// MARK: - Labeled Toggle
struct LabeledToggle: View {
    @Binding var isOn: Bool
    let label: String
    var subtitle: String?
    var size: AppToggle.ToggleSize = .medium
    var style: AppToggle.ToggleStyle = .standard
    var isEnabled: Bool = true
    var labelPosition: LabelPosition = .leading
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if labelPosition == .leading {
                labelContent
                Spacer()
                toggleContent
            } else {
                toggleContent
                Spacer()
                labelContent
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    private var labelContent: some View {
        VStack(alignment: labelPosition == .leading ? .leading : .trailing, spacing: AppSpacing.xs) {
            Text(label)
                .font(AppFonts.bodyMedium)
                .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFonts.captionLarge)
                    .foregroundColor(isEnabled ? AppColors.textSecondary : AppColors.textTertiary)
            }
        }
    }
    
    private var toggleContent: some View {
        AppToggle(
            isOn: $isOn,
            size: size,
            style: style,
            isEnabled: isEnabled
        )
    }
    
    enum LabelPosition {
        case leading
        case trailing
    }
}

// MARK: - Toggle List Item
struct ToggleListItem: View {
    @Binding var isOn: Bool
    let title: String
    var subtitle: String?
    var icon: String?
    var iconColor: Color = AppColors.primary
    var size: AppToggle.ToggleSize = .medium
    var style: AppToggle.ToggleStyle = .standard
    var isEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Icon
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: AppSpacing.iconMedium))
                    .foregroundColor(isEnabled ? iconColor : AppColors.textTertiary)
                    .frame(width: AppSpacing.iconLarge, height: AppSpacing.iconLarge)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.captionLarge)
                        .foregroundColor(isEnabled ? AppColors.textSecondary : AppColors.textTertiary)
                }
            }
            
            Spacer()
            
            // Toggle
            AppToggle(
                isOn: $isOn,
                size: size,
                style: style,
                isEnabled: isEnabled
            )
        }
        .padding(.appCard)
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cornerRadiusMedium)
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.toggle()
                }
            }
        }
    }
}

// MARK: - Toggle Group
struct ToggleGroup: View {
    let title: String
    var subtitle: String?
    let toggles: [ToggleItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.headlineSmall)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // Toggle Items
            VStack(spacing: AppSpacing.sm) {
                ForEach(Array(toggles.enumerated()), id: \.offset) { index, toggle in
                    LabeledToggle(
                        isOn: toggle.binding,
                        label: toggle.title,
                        subtitle: toggle.subtitle,
                        isEnabled: toggle.isEnabled
                    )
                    
                    if index < toggles.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.appCard)
            .background(AppColors.cardBackground)
            .cornerRadius(AppSpacing.cornerRadiusMedium)
            .cardShadow()
        }
    }
}

// MARK: - Toggle Item Model
struct ToggleItem {
    let title: String
    let subtitle: String?
    let binding: Binding<Bool>
    let isEnabled: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        binding: Binding<Bool>,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.binding = binding
        self.isEnabled = isEnabled
    }
}

#Preview("Toggle Examples") {
    @Previewable @State var toggle1 = false
    @Previewable @State var toggle2 = true
    @Previewable @State var toggle3 = false
    @Previewable @State var toggle4 = true
    @Previewable @State var toggle5 = false
    @Previewable @State var notifications = true
    @Previewable @State var darkMode = false
    @Previewable @State var analytics = true
    
    return ScrollView {
        VStack(spacing: AppSpacing.xl) {
            // Basic toggles
            VStack(spacing: AppSpacing.md) {
                Text("Basic Toggles").font(AppFonts.headlineSmall)
                
                HStack(spacing: AppSpacing.lg) {
                    AppToggle(isOn: $toggle1, size: .small)
                    AppToggle(isOn: $toggle2, size: .medium)
                    AppToggle(isOn: $toggle3, size: .large)
                }
                
                HStack(spacing: AppSpacing.lg) {
                    AppToggle(isOn: $toggle4, style: .success)
                    AppToggle(isOn: $toggle5, style: .warning)
                    AppToggle(isOn: .constant(false), style: .error, isEnabled: false)
                }
            }
            
            // Labeled toggles
            VStack(spacing: AppSpacing.md) {
                LabeledToggle(
                    isOn: $notifications,
                    label: "Push Notifications",
                    subtitle: "Receive notifications about your intentions"
                )
                
                LabeledToggle(
                    isOn: $darkMode,
                    label: "Dark Mode",
                    subtitle: "Use dark theme throughout the app",
                    labelPosition: .trailing
                )
            }
            
            // Toggle list items
            VStack(spacing: AppSpacing.sm) {
                ToggleListItem(
                    isOn: $notifications,
                    title: "Push Notifications",
                    subtitle: "Get reminders for your daily intentions",
                    icon: "bell.fill",
                    iconColor: AppColors.primary
                )
                
                ToggleListItem(
                    isOn: $analytics,
                    title: "Analytics",
                    subtitle: "Help improve the app with usage data",
                    icon: "chart.bar.fill",
                    iconColor: AppColors.info
                )
            }
            
            // Toggle group
            ToggleGroup(
                title: "Privacy Settings",
                subtitle: "Control how your data is used",
                toggles: [
                    ToggleItem(title: "Share Analytics", subtitle: "Anonymous usage data", binding: $analytics),
                    ToggleItem(title: "Crash Reports", subtitle: "Help us fix bugs", binding: $toggle1),
                    ToggleItem(title: "Marketing Emails", subtitle: "Product updates and tips", binding: $toggle2)
                ]
            )
        }
        .padding()
    }
} 