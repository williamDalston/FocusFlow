import SwiftUI

/// Agent 25: Validation Modifier - SwiftUI modifier for real-time input validation
/// Provides visual feedback (color changes) based on validation state
struct ValidationModifier: ViewModifier {
    let validation: ValidationResult
    let showError: Bool
    
    init(validation: ValidationResult, showError: Bool = true) {
        self.validation = validation
        self.showError = showError
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(borderColor, lineWidth: DesignSystem.Border.standard)
                )
            
            if showError, let errorMessage = validation.errorMessage {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.error)
                    
                    Text(errorMessage)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.error)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var borderColor: Color {
        switch validation {
        case .valid:
            return Theme.accentA.opacity(DesignSystem.Opacity.subtle)
        case .invalid:
            return Theme.error.opacity(DesignSystem.Opacity.strong)
        }
    }
}

extension View {
    /// Applies validation styling to a view
    /// - Parameters:
    ///   - validation: The validation result
    ///   - showError: Whether to show error message (default: true)
    /// - Returns: Modified view with validation styling
    func validation(_ validation: ValidationResult, showError: Bool = true) -> some View {
        modifier(ValidationModifier(validation: validation, showError: showError))
    }
}

// MARK: - Validation State

/// Observable object for managing validation state
@MainActor
class ValidationState: ObservableObject {
    @Published var validation: ValidationResult = .valid
    @Published var hasBeenTouched: Bool = false
    
    var isValid: Bool {
        validation.isValid
    }
    
    var errorMessage: String? {
        validation.errorMessage
    }
    
    func validate(_ value: String, validator: (String) -> ValidationResult) {
        validation = validator(value)
    }
    
    func validate<T>(_ value: T, validator: (T) -> ValidationResult) {
        validation = validator(value)
    }
    
    func touch() {
        hasBeenTouched = true
    }
    
    func reset() {
        validation = .valid
        hasBeenTouched = false
    }
}

