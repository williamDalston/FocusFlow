import SwiftUI

// MARK: - Enhanced Pull to Refresh

/// Agent 7: Enhanced pull-to-refresh modifier with animations and haptics
struct EnhancedPullToRefreshModifier: ViewModifier {
    let action: () async -> Void
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                await performRefresh()
            }
            .onChange(of: isRefreshing) { refreshing in
                if refreshing {
                    // Haptic feedback on refresh start
                    Haptics.refresh()
                    
                    // Rotation animation
                    withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    // Reset rotation
                    rotation = 0
                }
            }
    }
    
    private func performRefresh() async {
        isRefreshing = true
        await action()
        
        // Small delay for smooth transition
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        isRefreshing = false
    }
}

extension View {
    /// Enhanced pull-to-refresh with animations and haptics
    func enhancedRefreshable(action: @escaping () async -> Void) -> some View {
        modifier(EnhancedPullToRefreshModifier(action: action))
    }
}

/// Agent 7: Custom pull-to-refresh indicator
struct CustomRefreshIndicator: View {
    @State private var rotation: Double = 0
    let isRefreshing: Bool
    
    var body: some View {
        Group {
            if isRefreshing {
                LoadingIndicator(size: 24, color: Theme.accentA)
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: DesignSystem.IconSize.small, weight: .semibold))
                    .foregroundStyle(Theme.accentA)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            if !isRefreshing {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    rotation = 180
                }
            }
        }
    }
}

