import SwiftUI

/// Centralized color system for the app
/// Provides semantic color names that adapt to light/dark themes
enum AppColors {
    
    // MARK: - Primary Colors
    static let primary = Color.accentColor
    static let primaryLight = Color.accentColor.opacity(0.8)
    static let primaryDark = Color.accentColor.opacity(1.0)
    
    // MARK: - Background Colors
    static let background = Color(.systemBackground)
    static let surfaceBackground = Color(.secondarySystemBackground)
    static let cardBackground = Color(.systemBackground)
    static let elevated = Color(.systemBackground)
    
    // MARK: - Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(.tertiaryLabel)
    static let textInverse = Color(.systemBackground)
    
    // MARK: - Interactive Colors
    static let buttonPrimary = Color.accentColor
    static let buttonSecondary = Color(.systemGray4)
    
    // MARK: - Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    static let streakOrange = Color.orange
    static let progressGreen = Color.green
    
    // MARK: - Shadow & Border Colors
    static let shadowLight = Color(.black).opacity(0.05)
    static let shadowMedium = Color(.black).opacity(0.10)
    static let shadowStrong = Color(.black).opacity(0.15)
    static let border = Color(.separator)
}

// MARK: - Fallback Colors (for development, will be replaced)
struct FallbackColors {
    let background = Color(.systemGroupedBackground)
    let cardBackground = Color(.systemBackground)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    let primary = Color.blue
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
}

// MARK: - Color Extensions for convenience
extension Color {
    /// Quick access to app colors
    static let app = AppColors.self
} 