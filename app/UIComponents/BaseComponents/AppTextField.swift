import SwiftUI

/// Modern text field component with consistent styling
/// Supports different styles, states, and validation
struct AppTextField: View {
    @Binding var text: String
    let placeholder: String
    var style: FieldStyle = .outlined
    var size: FieldSize = .medium
    var state: FieldState = .normal
    var leadingIcon: String?
    var trailingIcon: String?
    var trailingAction: (() -> Void)?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var onEditingChanged: ((Bool) -> Void)?
    var onCommit: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Text Field Container
            HStack(spacing: AppSpacing.sm) {
                // Leading Icon
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(size.iconFont)
                        .foregroundColor(iconColor)
                }
                
                // Text Field
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .autocapitalization(autocapitalization)
                    }
                }
                .font(size.textFont)
                .foregroundColor(AppColors.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onCommit?()
                }
                .onChange(of: isFocused) { _, newValue in
                    onEditingChanged?(newValue)
                }
                
                // Trailing Icon/Action
                if let trailingIcon = trailingIcon {
                    Button(action: {
                        trailingAction?()
                    }) {
                        Image(systemName: trailingIcon)
                            .font(size.iconFont)
                            .foregroundColor(iconColor)
                    }
                    .disabled(trailingAction == nil)
                }
            }
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
        }
        .animation(.easeInOut(duration: AppSpacing.animationFast), value: isFocused)
        .animation(.easeInOut(duration: AppSpacing.animationFast), value: state)
    }
    
    // MARK: - Computed Properties
    private var borderColor: Color {
        if state == .error {
            return AppColors.error
        } else if state == .success {
            return AppColors.success
        } else if isFocused {
            return AppColors.primary
        } else {
            return style.borderColor
        }
    }
    
    private var borderWidth: CGFloat {
        if isFocused || state != .normal {
            return 2
        } else {
            return style == .outlined ? 1 : 0
        }
    }
    
    private var iconColor: Color {
        if state == .error {
            return AppColors.error
        } else if state == .success {
            return AppColors.success
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.textSecondary
        }
    }
}

// MARK: - Field Styles
extension AppTextField {
    enum FieldStyle {
        case filled
        case outlined
        case underlined
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .filled:
                return AppColors.surfaceBackground
            case .outlined:
                return AppColors.cardBackground
            case .underlined:
                return Color.clear
            case .ghost:
                return Color.clear
            }
        }
        
        var borderColor: Color {
            switch self {
            case .filled, .ghost:
                return Color.clear
            case .outlined:
                return AppColors.border
            case .underlined:
                return AppColors.border
            }
        }
    }
}

// MARK: - Field Sizes
extension AppTextField {
    enum FieldSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: AppSpacing.sm, leading: AppSpacing.md, bottom: AppSpacing.sm, trailing: AppSpacing.md)
            case .medium:
                return EdgeInsets(top: AppSpacing.md, leading: AppSpacing.lg, bottom: AppSpacing.md, trailing: AppSpacing.lg)
            case .large:
                return EdgeInsets(top: AppSpacing.lg, leading: AppSpacing.lg, bottom: AppSpacing.lg, trailing: AppSpacing.lg)
            }
        }
        
        var textFont: Font {
            switch self {
            case .small:
                return AppFonts.bodySmall
            case .medium:
                return AppFonts.bodyMedium
            case .large:
                return AppFonts.bodyLarge
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
            }
        }
    }
}

// MARK: - Field States
extension AppTextField {
    enum FieldState {
        case normal
        case error
        case success
        case disabled
    }
}

// MARK: - Form Field with Label
struct FormField: View {
    @Binding var text: String
    let label: String
    let placeholder: String
    var style: AppTextField.FieldStyle = .outlined
    var size: AppTextField.FieldSize = .medium
    var state: AppTextField.FieldState = .normal
    var isRequired: Bool = false
    var helpText: String?
    var errorText: String?
    var leadingIcon: String?
    var trailingIcon: String?
    var trailingAction: (() -> Void)?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var onEditingChanged: ((Bool) -> Void)?
    var onCommit: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Label
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFonts.labelMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                if isRequired {
                    Text("*")
                        .font(AppFonts.labelMedium)
                        .foregroundColor(AppColors.error)
                }
                
                Spacer()
            }
            
            // Text Field
            AppTextField(
                text: $text,
                placeholder: placeholder,
                style: style,
                size: size,
                state: state,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
                trailingAction: trailingAction,
                isSecure: isSecure,
                keyboardType: keyboardType,
                textContentType: textContentType,
                autocapitalization: autocapitalization,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
            
            // Help/Error Text
            if let errorText = errorText, state == .error {
                Text(errorText)
                    .font(AppFonts.captionLarge)
                    .foregroundColor(AppColors.error)
            } else if let helpText = helpText {
                Text(helpText)
                    .font(AppFonts.captionLarge)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Search Field
struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    var onSearchPressed: (() -> Void)?
    var onClear: (() -> Void)?
    
    var body: some View {
        AppTextField(
            text: $text,
            placeholder: placeholder,
            style: .filled,
            leadingIcon: "magnifyingglass",
            trailingIcon: text.isEmpty ? nil : "xmark.circle.fill",
            trailingAction: text.isEmpty ? nil : {
                text = ""
                onClear?()
            },
            keyboardType: .webSearch,
            autocapitalization: .none,
            onCommit: {
                onSearchPressed?()
            }
        )
    }
}

#Preview("Text Field Examples") {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            // Basic text fields
            AppTextField(text: .constant(""), placeholder: "Basic text field")
            
            AppTextField(
                text: .constant(""),
                placeholder: "With icons",
                leadingIcon: "person",
                trailingIcon: "checkmark.circle"
            )
            
            AppTextField(
                text: .constant(""),
                placeholder: "Error state",
                state: .error,
                leadingIcon: "exclamationmark.triangle"
            )
            
            AppTextField(
                text: .constant("Success!"),
                placeholder: "Success state",
                state: .success,
                trailingIcon: "checkmark.circle.fill"
            )
            
            // Different styles
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Styles").font(AppFonts.headlineSmall)
                
                AppTextField(text: .constant(""), placeholder: "Filled", style: .filled)
                AppTextField(text: .constant(""), placeholder: "Outlined", style: .outlined)
                AppTextField(text: .constant(""), placeholder: "Underlined", style: .underlined)
                AppTextField(text: .constant(""), placeholder: "Ghost", style: .ghost)
            }
            
            // Form field
            FormField(
                text: .constant(""),
                label: "Email Address",
                placeholder: "Enter your email",
                isRequired: true,
                helpText: "We'll never share your email",
                leadingIcon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none
            )
            
            // Search field
            SearchField(
                text: .constant(""),
                placeholder: "Search intentions..."
            )
        }
        .padding()
    }
} 