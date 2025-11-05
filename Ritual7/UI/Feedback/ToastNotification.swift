import SwiftUI

// MARK: - Agent 27: Enhanced Toast Notification System

/// Enhanced toast notification manager with undo support and multiple types
class ToastNotificationManager: ObservableObject {
    static let shared = ToastNotificationManager()
    
    @Published var currentToast: ToastNotification?
    private var toastTask: Task<Void, Never>?
    
    struct ToastNotification: Identifiable {
        let id = UUID()
        let message: String
        let icon: String
        let duration: TimeInterval
        let type: ToastType
        let undoAction: (() -> Void)?
        
        enum ToastType {
            case success
            case info
            case warning
            case error
            
            var color: Color {
                switch self {
                case .success: return .green
                case .info: return Theme.accentA
                case .warning: return .orange
                case .error: return .red
                }
            }
            
            var defaultIcon: String {
                switch self {
                case .success: return "checkmark.circle.fill"
                case .info: return "info.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .error: return "xmark.circle.fill"
                }
            }
        }
    }
    
    func show(
        _ message: String,
        icon: String? = nil,
        type: ToastNotification.ToastType = .success,
        duration: TimeInterval = 3.0,
        undoAction: (() -> Void)? = nil
    ) {
        toastTask?.cancel()
        
        let toast = ToastNotification(
            message: message,
            icon: icon ?? type.defaultIcon,
            duration: duration,
            type: type,
            undoAction: undoAction
        )
        
        currentToast = toast
        
        // Haptic feedback based on type
        switch type {
        case .success:
            Haptics.success()
        case .info:
            Haptics.gentle()
        case .warning:
            Haptics.warning()
        case .error:
            Haptics.error()
        }
        
        // Auto-dismiss after duration (unless it has undo)
        if undoAction == nil {
            toastTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                if !Task.isCancelled {
                    withAnimation(AnimationConstants.quickEase) {
                        currentToast = nil
                    }
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
    
    func performUndo() {
        currentToast?.undoAction?()
        dismiss()
    }
}

/// Enhanced toast notification view with undo support
struct ToastNotificationView: View {
    let toast: ToastNotificationManager.ToastNotification
    @StateObject private var manager = ToastNotificationManager.shared
    @State private var offset: CGFloat = -120
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: toast.icon)
                .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                .foregroundStyle(toast.type.color)
            
            // Message
            Text(toast.message)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Undo button (if available)
            if toast.undoAction != nil {
                Button {
                    manager.performUndo()
                    Haptics.buttonPress()
                } label: {
                    Text("Undo")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(toast.type.color)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(toast.type.color.opacity(DesignSystem.Opacity.subtle))
                        )
                }
            }
            
            // Dismiss button
            Button {
                manager.dismiss()
                Haptics.buttonPress()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: DesignSystem.IconSize.small, weight: DesignSystem.IconWeight.emphasis))
                    .foregroundStyle(.secondary)
                    .padding(DesignSystem.Spacing.xs / 2) // 4pt = half of xs
            }
        }
        .padding(DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(
            GlassCard(material: .regularMaterial) {
                EmptyView()
            }
            .overlay(
                // Colored accent on left edge
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .fill(toast.type.color)
                    .frame(width: 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .blur(radius: opacity < 0.5 ? 3 : 0)  // Subtle blur on entrance
        .onAppear {
            // Enhanced entrance animation with elegant spring
            withAnimation(AnimationConstants.elegantSpring) {
                offset = 0
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

/// Toast container view modifier
struct ToastNotificationContainerModifier: ViewModifier {
    @StateObject private var toastManager = ToastNotificationManager.shared
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let toast = toastManager.currentToast {
                ToastNotificationView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale))
                    .zIndex(9999)
                    .padding(.top, DesignSystem.Spacing.xl)
            }
        }
    }
}

extension View {
    /// Adds enhanced toast notification support to a view
    func toastNotificationContainer() -> some View {
        modifier(ToastNotificationContainerModifier())
    }
}

// MARK: - Convenience Extension for Easy Toast Usage

extension ToastNotificationManager {
    /// Show success toast
    func showSuccess(_ message: String, duration: TimeInterval = 2.0) {
        show(message, type: .success, duration: duration)
    }
    
    /// Show info toast
    func showInfo(_ message: String, duration: TimeInterval = 3.0) {
        show(message, type: .info, duration: duration)
    }
    
    /// Show warning toast
    func showWarning(_ message: String, duration: TimeInterval = 3.5) {
        show(message, type: .warning, duration: duration)
    }
    
    /// Show error toast
    func showError(_ message: String, duration: TimeInterval = 4.0) {
        show(message, type: .error, duration: duration)
    }
    
    /// Show toast with undo action
    func showWithUndo(_ message: String, undoAction: @escaping () -> Void, type: ToastNotification.ToastType = .info) {
        show(message, type: type, duration: 5.0, undoAction: undoAction)
    }
}

