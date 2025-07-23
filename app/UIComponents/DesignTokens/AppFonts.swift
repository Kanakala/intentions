import SwiftUI

/// Centralized typography system for the app
/// Provides semantic font styles with consistent hierarchy
enum AppFonts {
    
    // MARK: - Display Fonts (Large, impactful)
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Headline Fonts
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .default)
    
    // MARK: - Title Fonts
    static let titleLarge = Font.system(size: 18, weight: .medium, design: .default)
    static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
    static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
    
    // MARK: - Body Fonts
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Label Fonts
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Caption Fonts
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 11, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // MARK: - Button Fonts
    static let buttonLarge = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 15, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)
    
    // MARK: - Navigation Fonts
    static let navigationTitle = Font.system(size: 17, weight: .semibold, design: .default)
    static let tabBarItem = Font.system(size: 10, weight: .medium, design: .default)
    
    // MARK: - Semantic Font Aliases (for easy refactoring)
    static let cardTitle = headlineSmall
    static let cardSubtitle = bodySmall
    static let sectionHeader = titleMedium
    static let inputLabel = labelMedium
    static let placeholder = bodyMedium
    static let errorText = captionLarge
    
    // MARK: - Specialized Fonts
    static let monospacedNumber = Font.system(.body, design: .monospaced)
    static let roundedButton = Font.system(size: 16, weight: .semibold, design: .rounded)
}

// MARK: - Font Weight Extensions
extension Font.Weight {
    static let app = AppFontWeights()
}

struct AppFontWeights {
    let thin = Font.Weight.thin
    let ultraLight = Font.Weight.ultraLight
    let light = Font.Weight.light
    let regular = Font.Weight.regular
    let medium = Font.Weight.medium
    let semibold = Font.Weight.semibold
    let bold = Font.Weight.bold
    let heavy = Font.Weight.heavy
    let black = Font.Weight.black
}

// MARK: - Typography Helper Extension
extension Text {
    /// Apply app typography style
    func appStyle(_ font: Font) -> some View {
        self.font(font)
    }
    
    /// Common text combinations
    func cardTitle() -> some View {
        self.font(AppFonts.cardTitle)
            .foregroundColor(AppColors.textPrimary)
    }
    
    func cardSubtitle() -> some View {
        self.font(AppFonts.cardSubtitle)
            .foregroundColor(AppColors.textSecondary)
    }
    
    func sectionHeader() -> some View {
        self.font(AppFonts.sectionHeader)
            .foregroundColor(AppColors.textPrimary)
    }
} 