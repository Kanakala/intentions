import SwiftUI

/// Primary button component with modern design
/// Uses AppColors, AppFonts, AppSpacing, and AppShadows for consistency
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var size: ButtonSize = .medium
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var icon: String? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                action()
            }
        }) {
            HStack(spacing: AppSpacing.sm) {
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(style.foregroundColor)
                }
                
                // Icon
                if let icon = icon, !isLoading {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                // Title
                Text(title)
                    .font(size.textFont)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? style.foregroundColor : AppColors.textTertiary)
            .frame(maxWidth: size.maxWidth)
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(isEnabled ? style.backgroundColor : Color(.systemGray5))
            )
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animatedShadow(isPressed: $isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            withAnimation(.easeInOut(duration: AppSpacing.animationFast)) {
                isPressed = isPressing
            }
        } perform: {
            // Action handled in main button action
        }
        .animation(.easeInOut(duration: AppSpacing.animationFast), value: isEnabled)
        .animation(.easeInOut(duration: AppSpacing.animationFast), value: isLoading)
    }
}

// MARK: - Button Styles
extension PrimaryButton {
    enum ButtonStyle {
        case primary
        case secondary  
        case ghost
        case destructive
        case success
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return AppColors.buttonPrimary
            case .secondary:
                return AppColors.buttonSecondary
            case .ghost:
                return Color.clear
            case .destructive:
                return AppColors.error
            case .success:
                return AppColors.success
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .success:
                return AppColors.textInverse
            case .secondary:
                return AppColors.textPrimary
            case .ghost:
                return AppColors.primary
            }
        }
    }
}

// MARK: - Button Sizes
extension PrimaryButton {
    enum ButtonSize {
        case small
        case medium
        case large
        case extraLarge
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: AppSpacing.sm, leading: AppSpacing.md, bottom: AppSpacing.sm, trailing: AppSpacing.md)
            case .medium:
                return EdgeInsets(top: AppSpacing.md, leading: AppSpacing.lg, bottom: AppSpacing.md, trailing: AppSpacing.lg)
            case .large:
                return EdgeInsets(top: AppSpacing.lg, leading: AppSpacing.xl, bottom: AppSpacing.lg, trailing: AppSpacing.xl)
            case .extraLarge:
                return EdgeInsets(top: AppSpacing.xl, leading: AppSpacing.xxl, bottom: AppSpacing.xl, trailing: AppSpacing.xxl)
            }
        }
        
        var textFont: Font {
            switch self {
            case .small:
                return AppFonts.buttonSmall
            case .medium:
                return AppFonts.buttonMedium
            case .large:
                return AppFonts.buttonLarge
            case .extraLarge:
                return AppFonts.buttonLarge
            }
        }
        
        var iconFont: Font {
            switch self {
            case .small:
                return .system(size: AppSpacing.iconSmall)
            case .medium:
                return .system(size: AppSpacing.iconMedium)
            case .large:
                return .system(size: AppSpacing.iconLarge)
            case .extraLarge:
                return .system(size: AppSpacing.iconXLarge)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return AppSpacing.cornerRadiusSmall
            case .medium:
                return AppSpacing.cornerRadiusMedium
            case .large:
                return AppSpacing.cornerRadiusLarge
            case .extraLarge:
                return AppSpacing.cornerRadiusXLarge
            }
        }
        
        var maxWidth: CGFloat? {
            switch self {
            case .small, .medium:
                return nil
            case .large, .extraLarge:
                return .infinity
            }
        }
    }
}

// MARK: - Convenience Initializers
extension PrimaryButton {
    /// Create primary button
    static func primary(_ title: String, action: @escaping () -> Void) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .primary)
    }
    
    /// Create secondary button
    static func secondary(_ title: String, action: @escaping () -> Void) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .secondary)
    }
    
    /// Create ghost button
    static func ghost(_ title: String, action: @escaping () -> Void) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .ghost)
    }
    
    /// Create destructive button
    static func destructive(_ title: String, action: @escaping () -> Void) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .destructive)
    }
}

#Preview("Button Styles") {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton.primary("Primary Button") {}
        PrimaryButton.secondary("Secondary Button") {}
        PrimaryButton.ghost("Ghost Button") {}
        PrimaryButton.destructive("Delete") {}
        
        PrimaryButton(title: "With Icon", action: {}, icon: "star.fill")
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
} 