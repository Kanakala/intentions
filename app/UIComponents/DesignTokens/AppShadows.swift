import SwiftUI

/// Centralized shadow system for the app
/// Provides elevation levels for visual hierarchy and depth
enum AppShadows {
    
    // MARK: - Elevation Levels (Material Design inspired)
    static let elevation0 = ShadowStyle(
        color: Color.clear,
        radius: 0,
        x: 0,
        y: 0,
        opacity: 0
    )
    
    static let elevation1 = ShadowStyle(
        color: AppColors.shadowLight,
        radius: 2,
        x: 0,
        y: 1,
        opacity: 0.06
    )
    
    static let elevation2 = ShadowStyle(
        color: AppColors.shadowMedium,
        radius: 4,
        x: 0,
        y: 2,
        opacity: 0.08
    )
    
    static let elevation3 = ShadowStyle(
        color: AppColors.shadowMedium,
        radius: 6,
        x: 0,
        y: 3,
        opacity: 0.1
    )
    
    static let elevation4 = ShadowStyle(
        color: AppColors.shadowStrong,
        radius: 8,
        x: 0,
        y: 4,
        opacity: 0.12
    )
    
    static let elevation5 = ShadowStyle(
        color: AppColors.shadowStrong,
        radius: 12,
        x: 0,
        y: 6,
        opacity: 0.14
    )
    
    // MARK: - Semantic Shadow Aliases
    static let card = elevation2              // For intention cards
    static let button = elevation1            // For buttons
    static let buttonPressed = elevation0     // For pressed state
    static let modal = elevation4             // For modals and sheets
    static let dropdown = elevation3          // For dropdowns and menus
    static let fab = elevation3               // For floating action buttons
    static let fabPressed = elevation5        // For pressed FABs
    
    // MARK: - Specialized Shadows
    static let subtle = ShadowStyle(
        color: Color.black.opacity(0.03),
        radius: 3,
        x: 0,
        y: 1,
        opacity: 1.0
    )
    
    static let strong = ShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 15,
        x: 0,
        y: 8,
        opacity: 1.0
    )
    
    static let glow = ShadowStyle(
        color: AppColors.primary.opacity(0.3),
        radius: 8,
        x: 0,
        y: 0,
        opacity: 1.0
    )
    
    // MARK: - Interactive Shadows
    static let idle = elevation2
    static let hover = elevation3
    static let pressed = elevation1
    static let focused = ShadowStyle(
        color: AppColors.primary.opacity(0.2),
        radius: 4,
        x: 0,
        y: 0,
        opacity: 1.0
    )
}

// MARK: - Shadow Style Structure
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

// MARK: - View Extensions for Easy Shadow Application
extension View {
    /// Apply card shadow (elevation2)
    func cardShadow() -> some View {
        self.shadow(
            color: AppShadows.elevation2.color.opacity(AppShadows.elevation2.opacity),
            radius: AppShadows.elevation2.radius,
            x: AppShadows.elevation2.x,
            y: AppShadows.elevation2.y
        )
    }
    
    /// Apply button shadow (elevation3)
    func buttonShadow() -> some View {
        self.shadow(
            color: AppShadows.elevation3.color.opacity(AppShadows.elevation3.opacity),
            radius: AppShadows.elevation3.radius,
            x: AppShadows.elevation3.x,
            y: AppShadows.elevation3.y
        )
    }
    
    /// Apply floating shadow (elevation4)
    func floatingShadow() -> some View {
        self.shadow(
            color: AppShadows.elevation4.color.opacity(AppShadows.elevation4.opacity),
            radius: AppShadows.elevation4.radius,
            x: AppShadows.elevation4.x,
            y: AppShadows.elevation4.y
        )
    }
    
    /// Apply modal shadow (elevation5)
    func modalShadow() -> some View {
        self.shadow(
            color: AppShadows.elevation5.color.opacity(AppShadows.elevation5.opacity),
            radius: AppShadows.elevation5.radius,
            x: AppShadows.elevation5.x,
            y: AppShadows.elevation5.y
        )
    }
    
    /// Apply custom shadow using elevation level
    func applyShadow(_ elevation: ShadowStyle) -> some View {
        self.shadow(
            color: elevation.color.opacity(elevation.opacity),
            radius: elevation.radius,
            x: elevation.x,
            y: elevation.y
        )
    }
    
    /// Animated shadow that responds to pressed state
    func animatedShadow(isPressed: Binding<Bool>) -> some View {
        self.shadow(
            color: AppShadows.elevation3.color.opacity(isPressed.wrappedValue ? 0.02 : AppShadows.elevation3.opacity),
            radius: isPressed.wrappedValue ? 1 : AppShadows.elevation3.radius,
            x: AppShadows.elevation3.x,
            y: isPressed.wrappedValue ? 1 : AppShadows.elevation3.y
        )
    }
}

// MARK: - Elevation Levels
enum ElevationLevel {
    case none, low, medium, high, veryHigh, extreme
} 