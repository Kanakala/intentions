import SwiftUI

/// Versatile card component for sections and content containers
/// Uses design tokens for consistent styling across the app
struct SectionCard<Content: View>: View {
    let content: Content
    var style: CardStyle = .elevated
    var padding: EdgeInsets = .appCard
    var cornerRadius: CGFloat = AppSpacing.cornerRadiusMedium
    var showBorder: Bool = false
    
    init(
        style: CardStyle = .elevated,
        padding: EdgeInsets = .appCard,
        cornerRadius: CGFloat = AppSpacing.cornerRadiusMedium,
        showBorder: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(style.backgroundColor)
                    .overlay(
                        // Optional border
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppColors.border, lineWidth: showBorder ? AppSpacing.borderWidth : 0)
                    )
            )
            .cardShadow()
    }
}

// MARK: - Card Styles
extension SectionCard {
    enum CardStyle {
        case elevated       // Default elevated card with shadow
        case flat          // Flat card without shadow
        case outlined      // Outlined card with border
        case transparent   // Transparent background
        case subtle        // Subtle background tint
        
        var backgroundColor: Color {
            switch self {
            case .elevated, .flat:
                return AppColors.cardBackground
            case .outlined:
                return AppColors.background
            case .transparent:
                return Color.clear
            case .subtle:
                return AppColors.surfaceBackground
            }
        }
    }
}

// MARK: - Convenience Modifiers
extension SectionCard {
    /// Apply tight padding
    func tightPadding() -> SectionCard {
        SectionCard(
            style: style,
            padding: EdgeInsets.all(AppSpacing.md),
            cornerRadius: cornerRadius,
            showBorder: showBorder
        ) {
            content
        }
    }
    
    /// Apply loose padding
    func loosePadding() -> SectionCard {
        SectionCard(
            style: style,
            padding: EdgeInsets.all(AppSpacing.xxl),
            cornerRadius: cornerRadius,
            showBorder: showBorder
        ) {
            content
        }
    }
    
    /// Apply custom corner radius
    func customCornerRadius(_ radius: CGFloat) -> SectionCard {
        SectionCard(
            style: style,
            padding: padding,
            cornerRadius: radius,
            showBorder: showBorder
        ) {
            content
        }
    }
}

// MARK: - Specialized Card Components
/// Header card for sections with title and optional subtitle
struct HeaderCard: View {
    let title: String
    let subtitle: String?
    let icon: String?
    var style: SectionCard<AnyView>.CardStyle = .elevated
    
    var body: some View {
        SectionCard(style: style) {
            AnyView(
                HStack(spacing: AppSpacing.md) {
                    // Icon
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: AppSpacing.iconLarge, weight: .medium))
                            .foregroundColor(AppColors.primary)
                    }
                    
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
                    
                    Spacer()
                }
            )
        }
    }
}

/// Stats card for displaying metrics
struct StatsCard: View {
    let value: String
    let label: String
    let icon: String?
    let color: Color
    var style: SectionCard<AnyView>.CardStyle = .elevated
    
    var body: some View {
        SectionCard(style: style) {
            AnyView(
                VStack(spacing: AppSpacing.sm) {
                    HStack {
                        if let icon = icon {
                            Image(systemName: icon)
                                .foregroundColor(color)
                        }
                        Spacer()
                    }
                    
                    Text(value)
                        .font(AppFonts.displaySmall)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text(label)
                        .font(AppFonts.captionLarge)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            )
        }
        .tightPadding()
    }
}

/// Action card with button-like behavior
struct ActionCard: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let action: () -> Void
    var style: SectionCard<AnyView>.CardStyle = .elevated
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            SectionCard(style: style) {
                AnyView(
                    HStack(spacing: AppSpacing.md) {
                        // Icon
                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: AppSpacing.iconLarge))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(title)
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.textPrimary)
                            
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(AppFonts.captionLarge)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: AppSpacing.iconSmall))
                            .foregroundColor(AppColors.textTertiary)
                    }
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            withAnimation(.easeInOut(duration: AppSpacing.animationFast)) {
                isPressed = isPressing
            }
        } perform: {
            // Action handled by button
        }
    }
}

#Preview("Card Examples") {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            // Basic cards
            SectionCard(style: .elevated) {
                Text("Elevated Card")
                    .font(AppFonts.titleMedium)
            }
            
            SectionCard(style: .flat) {
                Text("Flat Card")
                    .font(AppFonts.titleMedium)
            }
            
            SectionCard(style: .outlined, showBorder: true) {
                Text("Outlined Card")
                    .font(AppFonts.titleMedium)
            }
            
            // Header card
            HeaderCard(
                title: "Settings",
                subtitle: "Manage your preferences",
                icon: "gear"
            )
            
            // Stats cards
            HStack(spacing: AppSpacing.md) {
                StatsCard(
                    value: "42",
                    label: "Streak Days",
                    icon: "flame.fill",
                    color: AppColors.streakOrange
                )
                
                StatsCard(
                    value: "87%",
                    label: "Success Rate",
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppColors.progressGreen
                )
            }
            
            // Action card
            ActionCard(
                title: "Add New Item",
                subtitle: "Create a new intention",
                icon: "plus.circle.fill",
                action: { print("Card tapped") }
            )
        }
        .padding()
    }
} 