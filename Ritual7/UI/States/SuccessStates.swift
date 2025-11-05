import SwiftUI

// MARK: - Success State Components

/// Agent 7: Success view with bounce animation
struct SuccessStateView: View {
    let message: String
    let icon: String
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var isVisible = false
    
    init(message: String, icon: String = "checkmark.circle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.huge, weight: .medium))
                .foregroundStyle(.green)
                .scaleEffect(scale)
                .opacity(opacity)
            
            Text(message)
                .font(Theme.title3)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            GlassCard(material: .ultraThinMaterial) {
                EmptyView()
            }
        )
        .cardShadow()
        .onAppear {
            // Bounce animation
            withAnimation(AnimationConstants.bouncySpring) {
                scale = 1.2
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.0
                }
            }
            
            // Entrance animation
            withAnimation(AnimationConstants.quickEase) {
                isVisible = true
            }
            
            Haptics.success()
        }
    }
}

/// Agent 7: Toast notification system
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var currentToast: Toast?
    private var toastTask: Task<Void, Never>?
    
    struct Toast: Identifiable {
        let id = UUID()
        let message: String
        let icon: String
        let duration: TimeInterval
        let type: ToastType
        
        enum ToastType {
            case success
            case info
            case warning
        }
        
        var color: Color {
            switch type {
            case .success: return .green
            case .info: return Theme.accentA
            case .warning: return .orange
            }
        }
    }
    
    func show(_ message: String, icon: String = "checkmark.circle.fill", type: Toast.ToastType = .success, duration: TimeInterval = 2.0) {
        toastTask?.cancel()
        
        let toast = Toast(message: message, icon: icon, duration: duration, type: type)
        currentToast = toast
        
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if !Task.isCancelled {
                withAnimation(AnimationConstants.quickEase) {
                    currentToast = nil
                }
            }
        }
    }
    
    func dismiss() {
        toastTask?.cancel()
        withAnimation(AnimationConstants.quickEase) {
            currentToast = nil
        }
    }
}

/// Agent 7: Toast notification view
struct ToastView: View {
    let toast: ToastManager.Toast
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: toast.icon)
                .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                .foregroundStyle(toast.color)
            
            Text(toast.message)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(
            GlassCard(material: .regularMaterial) {
                EmptyView()
            }
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(AnimationConstants.smoothSpring) {
                offset = 0
                opacity = 1.0
            }
            
            Haptics.success()
        }
        .onTapGesture {
            ToastManager.shared.dismiss()
        }
    }
}

/// Agent 7: Toast container view modifier
struct ToastContainerModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let toast = toastManager.currentToast {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(9999)
                    .padding(.top, DesignSystem.Spacing.xl)
            }
        }
    }
}

extension View {
    /// Adds toast notification support to a view
    func toastContainer() -> some View {
        modifier(ToastContainerModifier())
    }
}

/// Agent 7: Success feedback modifier
struct SuccessFeedbackModifier: ViewModifier {
    let trigger: Bool
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { newValue in
                if newValue {
                    withAnimation(AnimationConstants.bouncySpring) {
                        scale = 1.15
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(AnimationConstants.smoothSpring) {
                            scale = 1.0
                        }
                    }
                    Haptics.success()
                }
            }
    }
}

extension View {
    /// Adds success bounce animation to a view
    func successFeedback(trigger: Bool) -> some View {
        modifier(SuccessFeedbackModifier(trigger: trigger))
    }
}

