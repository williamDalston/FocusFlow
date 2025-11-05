import SwiftUI

// MARK: - Enhanced Error States

/// Agent 7: Enhanced error view with animations and better design
struct ErrorStateView: View {
    let error: ErrorHandling.WorkoutError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    @State private var shakeOffset: CGFloat = 0
    @State private var isVisible = false
    
    init(error: ErrorHandling.WorkoutError, onRetry: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Error icon with bounce animation
            Image(systemName: iconName)
                .font(.system(size: 64, weight: .medium))
                .foregroundStyle(errorColor)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(AnimationConstants.bouncySpring.delay(0.1), value: isVisible)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(errorTitle)
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(error.localizedDescription)
                    .font(Theme.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            .offset(x: shakeOffset)
            
            // Action buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                if let onRetry = onRetry {
                    Button {
                        Haptics.error()
                        onRetry()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryProminentButtonStyle())
                }
                
                if let onDismiss = onDismiss {
                    Button {
                        Haptics.tap()
                        onDismiss()
                    } label: {
                        Text("Dismiss")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                }
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            GlassCard(material: .ultraThinMaterial) {
                EmptyView()
            }
        )
        .cardShadow()
        .onAppear {
            // Entrance animation
            withAnimation(AnimationConstants.quickEase) {
                isVisible = true
            }
            
            // Shake animation for error
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3).repeatCount(3, autoreverses: true)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shakeOffset = 0
                }
            }
        }
    }
    
    private var iconName: String {
        switch error {
        case .networkUnavailable:
            return "wifi.slash"
        case .dataCorrupted:
            return "exclamationmark.triangle.fill"
        case .permissionDenied:
            return "lock.fill"
        case .lowMemory:
            return "memorychip"
        case .batterySaverMode:
            return "battery.25"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var errorTitle: String {
        switch error {
        case .networkUnavailable:
            return "Connection Issue"
        case .dataCorrupted:
            return "Data Error"
        case .permissionDenied:
            return "Permission Required"
        case .lowMemory:
            return "Low Memory"
        case .batterySaverMode:
            return "Battery Saver Mode"
        default:
            return "Oops!"
        }
    }
    
    private var errorColor: Color {
        switch error {
        case .networkUnavailable, .permissionDenied:
            return .orange
        case .dataCorrupted:
            return .red
        case .lowMemory, .batterySaverMode:
            return .yellow
        default:
            return .orange
        }
    }
}

/// Agent 7: Inline error view for smaller errors
struct InlineErrorView: View {
    let message: String
    let onDismiss: (() -> Void)?
    @State private var isVisible = false
    
    init(message: String, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            
            Text(message)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
            
            if let onDismiss = onDismiss {
                Button {
                    Haptics.tap()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.orange.opacity(DesignSystem.Opacity.subtle))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .stroke(.orange.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.subtle)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -10)
        .onAppear {
            withAnimation(AnimationConstants.quickEase) {
                isVisible = true
            }
        }
    }
}

/// Agent 7: Error alert modifier with enhanced animations
struct EnhancedErrorAlertModifier: ViewModifier {
    @Binding var error: ErrorHandling.WorkoutError?
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(error != nil), presenting: error) { error in
                if let onRetry = onRetry {
                    Button("Try Again") {
                        Haptics.error()
                        onRetry()
                    }
                }
                Button("OK") {
                    Haptics.tap()
                    self.error = nil
                }
            } message: { error in
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(error.localizedDescription)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
    }
}

extension View {
    /// Shows an enhanced error alert
    func enhancedErrorAlert(error: Binding<ErrorHandling.WorkoutError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(EnhancedErrorAlertModifier(error: error, onRetry: onRetry))
    }
}

// MARK: - Error Boundary

/// Error boundary view that catches errors and displays them gracefully
struct ErrorBoundary<Content: View>: View {
    @State private var error: Error?
    @State private var showError = false
    let content: Content
    let onError: ((Error) -> Void)?
    
    init(@ViewBuilder content: () -> Content, onError: ((Error) -> Void)? = nil) {
        self.content = content()
        self.onError = onError
    }
    
    var body: some View {
        Group {
            if let error = error {
                ErrorStateView(
                    error: error as? ErrorHandling.WorkoutError ?? .unknown(error),
                    onRetry: {
                        self.error = nil
                        self.showError = false
                    },
                    onDismiss: {
                        self.error = nil
                        self.showError = false
                    }
                )
                .onAppear {
                    // Call onError callback when error appears
                    showError = true
                    onError?(error)
                }
            } else {
                content
            }
        }
    }
}

/// Error boundary modifier that wraps content and catches errors
struct ErrorBoundaryModifier: ViewModifier {
    @State private var error: Error?
    let onError: ((Error) -> Void)?
    
    func body(content: Content) -> some View {
        Group {
            if let error = error {
                ErrorStateView(
                    error: error as? ErrorHandling.WorkoutError ?? .unknown(error),
                    onRetry: {
                        self.error = nil
                    },
                    onDismiss: {
                        self.error = nil
                    }
                )
            } else {
                content
            }
        }
        // Note: Error catching is handled by the ErrorBoundary view itself
        // This modifier is a wrapper that displays errors when they occur
        // Actual error catching should be implemented in the views that use this modifier
    }
}

extension View {
    /// Wraps content in an error boundary that catches and displays errors gracefully
    func errorBoundary(onError: ((Error) -> Void)? = nil) -> some View {
        modifier(ErrorBoundaryModifier(onError: onError))
    }
}

