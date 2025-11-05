import SwiftUI

// MARK: - Agent 27: Progress Indicator Components

/// Linear progress indicator for long-running operations
struct LinearProgressIndicator: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, color: Color = Theme.accentA, height: CGFloat = 4) {
        self.progress = progress.clamped(to: 0...1)
        self.color = color
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(color.opacity(DesignSystem.Opacity.subtle))
                
                // Enhanced progress bar with animated gradient
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color,
                                color.opacity(0.9),
                                color.opacity(0.8),
                                color.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress)
                    .shadow(color: color.opacity(DesignSystem.Opacity.glow * 0.8), radius: 4, x: 0, y: 2)
                    .shadow(color: color.opacity(DesignSystem.Opacity.medium), radius: 2, x: 0, y: 1)
                    .overlay(
                        // Subtle shimmer effect
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * animatedProgress * 0.3)
                        .offset(x: -geometry.size.width * animatedProgress * 0.7)
                        .blendMode(.overlay)
                    )
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(AnimationConstants.progressLinear) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(AnimationConstants.progressLinear) {
                animatedProgress = newValue
            }
        }
    }
}

/// Circular progress indicator for operations
struct CircularProgressIndicator: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat
    @State private var animatedProgress: Double = 0
    @State private var rotation: Double = 0
    
    init(progress: Double, color: Color = Theme.accentA, size: CGFloat = 40, lineWidth: CGFloat = 4) {
        self.progress = progress.clamped(to: 0...1)
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(DesignSystem.Opacity.subtle), lineWidth: lineWidth)
            
            // Enhanced progress circle with animated gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [
                            color,
                            color.opacity(0.9),
                            color.opacity(0.8),
                            color.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(DesignSystem.Opacity.glow * 0.8), radius: 4, x: 0, y: 2)
                .shadow(color: color.opacity(DesignSystem.Opacity.medium), radius: 2)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(AnimationConstants.progressLinear) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(AnimationConstants.progressLinear) {
                animatedProgress = newValue
            }
        }
    }
}

/// Indeterminate progress indicator (spinning)
struct IndeterminateProgressIndicator: View {
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat
    @State private var rotation: Double = 0
    
    init(color: Color = Theme.accentA, size: CGFloat = 40, lineWidth: CGFloat = 4) {
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(DesignSystem.Opacity.subtle), lineWidth: lineWidth)
            
            // Animated arc
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation))
                .shadow(color: color.opacity(DesignSystem.Opacity.medium), radius: 2)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// Progress indicator with label
struct ProgressIndicatorWithLabel: View {
    let progress: Double?
    let label: String
    let color: Color
    let style: ProgressStyle
    
    enum ProgressStyle {
        case linear
        case circular
        case indeterminate
    }
    
    init(
        progress: Double? = nil,
        label: String,
        color: Color = Theme.accentA,
        style: ProgressStyle = .linear
    ) {
        self.progress = progress?.clamped(to: 0...1)
        self.label = label
        self.color = color
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Progress indicator
            switch style {
            case .linear:
                if let progress = progress {
                    LinearProgressIndicator(progress: progress, color: color)
                } else {
                    LinearProgressIndicator(progress: 0.5, color: color)
                        .overlay(
                            IndeterminateProgressIndicator(color: color, size: 20, lineWidth: 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        )
                }
                
            case .circular:
                if let progress = progress {
                    CircularProgressIndicator(progress: progress, color: color)
                } else {
                    IndeterminateProgressIndicator(color: color)
                }
                
            case .indeterminate:
                if let progress = progress {
                    CircularProgressIndicator(progress: progress, color: color)
                } else {
                    IndeterminateProgressIndicator(color: color)
                }
            }
            
            // Label
            Text(label)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.md)
    }
}

// MARK: - Progress Overlay

/// Full-screen progress overlay for long operations
struct ProgressOverlay: View {
    let progress: Double?
    let message: String?
    let isVisible: Bool
    
    init(progress: Double? = nil, message: String? = nil, isVisible: Bool = true) {
        self.progress = progress?.clamped(to: 0...1)
        self.message = message
        self.isVisible = isVisible
    }
    
    var body: some View {
        if isVisible {
            ZStack {
                // Background
                Color.black.opacity(DesignSystem.Opacity.overlay * 0.6)
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: DesignSystem.Spacing.lg) {
                    if let progress = progress {
                        CircularProgressIndicator(progress: progress, size: 60, lineWidth: 6)
                    } else {
                        IndeterminateProgressIndicator(size: 60, lineWidth: 6)
                    }
                    
                    if let message = message {
                        Text(message)
                            .font(Theme.subheadline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let progress = progress {
                        Text("\(Int(progress * 100))%")
                            .font(Theme.title3.monospacedDigit())
                            .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                    }
                }
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    GlassCard(material: .ultraThinMaterial) {
                        EmptyView()
                    }
                )
                .cardShadow()
                .padding(DesignSystem.Spacing.xxl)
            }
            .transition(.opacity.combined(with: .scale))
            .zIndex(9998)
        }
    }
}

// MARK: - Helper Extensions

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}

