import SwiftUI

/// Agent 25: Undo Toast View - Toast notification with undo option
/// Displays a temporary notification that can be dismissed or undone
struct UndoToastView: View {
    let message: String
    let onUndo: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    @State private var isVisible = false
    @State private var dismissTask: Task<Void, Never>?
    
    init(message: String, onUndo: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onUndo = onUndo
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(Theme.title3)
                .foregroundStyle(Theme.accentA)
            
            Text(message)
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
            
            Spacer()
            
            if let onUndo = onUndo {
                Button {
                    onUndo()
                    dismiss()
                } label: {
                    Text("Undo")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.accentA)
                }
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(Theme.accentA.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
                )
        )
        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.medium), 
               radius: DesignSystem.Shadow.medium.radius, 
               x: 0, 
               y: DesignSystem.Shadow.medium.y)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -100)
        .onAppear {
            show()
        }
        .onDisappear {
            dismissTask?.cancel()
        }
    }
    
    private func show() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = true
        }
        
        // Auto-dismiss after 5 seconds
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if !Task.isCancelled {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = false
        }
        
        // Call onDismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss?()
        }
    }
}

// MARK: - Toast Manager

/// Manager for displaying toast notifications globally
@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var currentToast: ToastItem?
    
    private init() {}
    
    func show(message: String, onUndo: (() -> Void)? = nil, duration: TimeInterval = 5.0) {
        currentToast = ToastItem(
            message: message,
            onUndo: onUndo,
            duration: duration
        )
    }
    
    func dismiss() {
        currentToast = nil
    }
}

/// Represents a toast notification item
struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let onUndo: (() -> Void)?
    let duration: TimeInterval
    
    init(message: String, onUndo: (() -> Void)? = nil, duration: TimeInterval = 5.0) {
        self.message = message
        self.onUndo = onUndo
        self.duration = duration
    }
}

// MARK: - Toast Container

/// Container view for displaying toast notifications
struct ToastContainer: View {
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        ZStack {
            if let toast = toastManager.currentToast {
                VStack {
                    Spacer()
                    
                    UndoToastView(
                        message: toast.message,
                        onUndo: toast.onUndo,
                        onDismiss: {
                            toastManager.dismiss()
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                .zIndex(1000)
            }
        }
    }
}

// MARK: - Toast View Modifier

extension View {
    /// Adds toast notification support to a view
    func toast() -> some View {
        self.overlay(
            ToastContainer()
                .allowsHitTesting(false)
        )
    }
}

