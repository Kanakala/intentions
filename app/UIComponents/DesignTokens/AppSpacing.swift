import SwiftUI

/// Centralized spacing system for the app
/// Based on 4pt grid system for consistency and scalability
enum AppSpacing {
    
    // MARK: - Base Spacing (4pt grid)
    static let xxs: CGFloat = 2      // 2pt - Micro spacing
    static let xs: CGFloat = 4       // 4pt - Tiny spacing
    static let sm: CGFloat = 8       // 8pt - Small spacing
    static let md: CGFloat = 12      // 12pt - Medium spacing
    static let lg: CGFloat = 16      // 16pt - Large spacing
    static let xl: CGFloat = 20      // 20pt - Extra large spacing
    static let xxl: CGFloat = 24     // 24pt - Extra extra large
    static let xxxl: CGFloat = 32    // 32pt - Massive spacing
    
    // MARK: - Semantic Spacing Aliases
    static let micro = xxs
    static let tiny = xs
    static let small = sm
    static let medium = md
    static let large = lg
    static let extraLarge = xl
    static let huge = xxl
    static let massive = xxxl
    
    // MARK: - Component Spacing
    static let buttonPadding = EdgeInsets(top: md, leading: xl, bottom: md, trailing: xl)
    static let cardPadding = EdgeInsets(top: lg, leading: lg, bottom: lg, trailing: lg)
    static let sectionPadding = EdgeInsets(top: lg, leading: lg, bottom: lg, trailing: lg)
    static let screenPadding = EdgeInsets(top: lg, leading: lg, bottom: lg, trailing: lg)
    
    // MARK: - Layout Spacing
    static let sectionSpacing: CGFloat = xxl        // Between major sections
    static let cardSpacing: CGFloat = lg            // Between cards
    static let elementSpacing: CGFloat = md         // Between elements in a section
    static let tightSpacing: CGFloat = sm           // Between closely related elements
    static let labelSpacing: CGFloat = xs           // Between label and input
    
    // MARK: - Touch Target & Accessibility
    static let minTouchTarget: CGFloat = 44         // Apple HIG minimum
    static let comfortableTouchTarget: CGFloat = 56  // More comfortable tap area
    
    // MARK: - Border & Corner Radius
    static let borderWidth: CGFloat = 1
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 20
    static let cornerRadiusCircle: CGFloat = 50     // For circular elements
    
    // MARK: - Shadow Properties
    static let shadowRadius: CGFloat = 8
    static let shadowOffset = CGSize(width: 0, height: 2)
    static let shadowOpacity: Double = 0.1
    
    // MARK: - Icon Sizes
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    static let iconHuge: CGFloat = 48
    
    // MARK: - Content Width Constraints
    static let maxContentWidth: CGFloat = 400       // For forms and reading content
    static let maxCardWidth: CGFloat = 350          // For intention cards
    
    // MARK: - Animation Durations
    static let animationFast: TimeInterval = 0.2
    static let animationMedium: TimeInterval = 0.3
    static let animationSlow: TimeInterval = 0.5
    
    // MARK: - Grid System
    static let gridColumns = 2                      // For card grids
    static let gridSpacing: CGFloat = md
}

// MARK: - EdgeInsets Extensions
extension EdgeInsets {
    /// All sides equal padding
    static func all(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
    
    /// Horizontal and vertical padding
    static func symmetric(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> EdgeInsets {
        EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
    /// Individual sides
    static func only(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> EdgeInsets {
        EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
    
    // MARK: - Semantic Padding Presets
    static let appPadding = EdgeInsets.all(AppSpacing.lg)
    static let appCard = EdgeInsets.all(AppSpacing.lg)
    static let appSection = EdgeInsets.all(AppSpacing.lg)
    static let appContent = EdgeInsets.all(AppSpacing.md)
    static let appCompact = EdgeInsets.all(AppSpacing.sm)
}

// MARK: - View Extensions for Spacing
extension View {
    /// Apply app-standard padding
    func appPadding(_ style: AppPaddingStyle = .standard) -> some View {
        switch style {
        case .standard:
            return self.padding(AppSpacing.lg)
        case .tight:
            return self.padding(AppSpacing.md)
        case .loose:
            return self.padding(AppSpacing.xxl)
        case .card:
            return self.padding(EdgeInsets.appCard)
        case .screen:
            return self.padding(EdgeInsets.appSection)
        }
    }
    
    /// Apply corner radius with app standards
    func appCornerRadius(_ style: AppCornerRadiusStyle = .medium) -> some View {
        switch style {
        case .small:
            return self.clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
        case .medium:
            return self.clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
        case .large:
            return self.clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        case .xlarge:
            return self.clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusXLarge))
        }
    }
}

// MARK: - Padding Style Enums
enum AppPaddingStyle {
    case standard, tight, loose, card, screen
}

enum AppCornerRadiusStyle {
    case small, medium, large, xlarge
} 