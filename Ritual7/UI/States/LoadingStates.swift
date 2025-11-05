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
/// Agent 16: Enhanced to match actual StatBox layout
struct SkeletonStatBox: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Icon placeholder (matches StatBox icon layout)
            ZStack {
                Circle()
                    .fill(Theme.accentA.opacity(DesignSystem.Opacity.highlight))
                    .frame(width: DesignSystem.IconSize.statBox + 8, height: DesignSystem.IconSize.statBox + 8)
                    .overlay(ShimmerView())
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
                    .overlay(ShimmerView())
            }
            
            // Large number placeholder (matches AnimatedGradientCounter)
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                .fill(.ultraThinMaterial)
                .frame(width: 80, height: 48)
                .overlay(ShimmerView())
            
            // Title placeholder
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                .fill(.ultraThinMaterial)
                .frame(width: 100, height: 12)
                .overlay(ShimmerView())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .regularCardPadding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.5),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.5),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
        )
        .softShadow()
    }
}

// MARK: - Agent 16: Additional Skeleton Components

/// Agent 16: Skeleton loader for list items (workout history rows)
struct SkeletonList: View {
    let count: Int
    
    init(count: Int = 5) {
        self.count = count
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                SkeletonListItem()
                    .staggeredEntrance(index: index, delay: 0.04)
            }
        }
    }
}

/// Agent 16: Skeleton loader for individual list items
struct SkeletonListItem: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon placeholder
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
                .overlay(ShimmerView())
            
            // Content placeholders
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 16)
                    .overlay(ShimmerView())
                
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 12)
                    .overlay(ShimmerView())
            }
            
            Spacer()
            
            // Trailing placeholder
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 14)
                .overlay(ShimmerView())
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
        .softShadow()
    }
}

/// Agent 16: Skeleton loader for chart views
struct SkeletonChart: View {
    let height: CGFloat
    
    init(height: CGFloat = 200) {
        self.height = height
    }
    
    private var barHeights: [CGFloat] {
        [80, 120, 90, 140, 100, 130, 110]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Title placeholder
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs)
                .fill(.ultraThinMaterial)
                .frame(width: 150, height: 20)
                .overlay(ShimmerView())
            
            // Chart area placeholder
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: height)
                .overlay(
                    // Chart bars/lines placeholder
                    HStack(alignment: .bottom, spacing: DesignSystem.Spacing.sm) {
                        ForEach(0..<7, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(width: 30, height: barHeights[index])
                                .overlay(ShimmerView())
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
                )
                .overlay(ShimmerView())
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
    }
}

/// Agent 16: Skeleton loader for workout content grid
struct SkeletonStatsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.gridSpacing) {
            ForEach(0..<4, id: \.self) { index in
                SkeletonStatBox()
                    .staggeredEntrance(index: index, delay: 0.05)
            }
        }
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

// MARK: - Agent 16: Smooth Transition Helpers

/// Agent 16: Smooth transition modifier for loading states
struct LoadingTransitionModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .scaleEffect(isLoading ? 0.95 : 1.0)
            .animation(AnimationConstants.smoothSpring, value: isLoading)
    }
}

extension View {
    /// Smoothly transitions between loading and loaded states
    func loadingTransition(_ isLoading: Bool) -> some View {
        modifier(LoadingTransitionModifier(isLoading: isLoading))
    }
}

