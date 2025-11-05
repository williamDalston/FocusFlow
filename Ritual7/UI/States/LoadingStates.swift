import SwiftUI

// MARK: - Loading State Components

/// Agent 7: Beautiful loading indicator with smooth animation
struct LoadingIndicator: View {
    @State private var rotation: Double = 0
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Theme.accentA) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(DesignSystem.Opacity.light), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(rotation))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// Agent 7: Shimmer effect for loading states
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    let duration: Double
    
    init(duration: Double = 1.8) {
        self.duration = duration
    }
    
    var body: some View {
        LinearGradient(
            colors: [
                .clear,
                .white.opacity(DesignSystem.Opacity.shimmer),
                .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: phase * 300)
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}

/// Agent 7: Skeleton loader for cards and content
struct SkeletonCard: View {
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(height: CGFloat = 120, cornerRadius: CGFloat = DesignSystem.CornerRadius.card) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(height: height)
            .overlay(
                ShimmerView()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
            )
            .softShadow()
    }
}

/// Agent 7: Skeleton loader for stat boxes
struct SkeletonStatBox: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Icon placeholder
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
                .overlay(ShimmerView())
            
            // Text placeholders
            VStack(spacing: DesignSystem.Spacing.xs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 16)
                    .overlay(ShimmerView())
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 12)
                    .overlay(ShimmerView())
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
        )
        .softShadow()
    }
}

/// Agent 7: Loading state view with message
struct LoadingStateView: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            LoadingIndicator(size: 32, color: Theme.accentA)
            
            if let message = message {
                Text(message)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxl)
    }
}

/// Agent 7: Full-screen loading overlay
struct LoadingOverlay: View {
    let message: String?
    @State private var isVisible = false
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(DesignSystem.Opacity.overlay * 0.5)
                .ignoresSafeArea()
            
            GlassCard(material: .ultraThinMaterial) {
                LoadingStateView(message: message)
            }
            .padding(DesignSystem.Spacing.xxl)
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(AnimationConstants.quickEase) {
                isVisible = true
            }
        }
    }
}

// MARK: - Button Loading State

/// Agent 7: Loading button state modifier
struct LoadingButtonModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if isLoading {
                LoadingIndicator(size: 16, color: .white)
                    .transition(.opacity.combined(with: .scale))
            }
            
            content
                .opacity(isLoading ? 0.7 : 1.0)
        }
        .animation(AnimationConstants.quickEase, value: isLoading)
    }
}

extension View {
    /// Shows a loading indicator in a button
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingButtonModifier(isLoading: isLoading))
    }
}

