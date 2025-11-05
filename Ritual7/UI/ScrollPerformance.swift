import SwiftUI

// MARK: - Scroll Performance Optimizations

/// Scroll-aware shadow modifier that defers heavy shadows during scroll to maintain 60fps
/// Uses opacity fade during scroll transitions for smooth performance
struct ScrollAwareShadow: ViewModifier {
    @State private var isScrolling = false
    @State private var scrollTask: Task<Void, Never>?
    
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowY: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(isScrolling ? shadowOpacity * 0.3 : shadowOpacity),
                radius: isScrolling ? shadowRadius * 0.5 : shadowRadius,
                x: 0,
                y: isScrolling ? shadowY * 0.5 : shadowY
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                // Debounce scroll detection to avoid excessive updates
                let wasScrolling = isScrolling
                scrollTask?.cancel()
                
                // Detect scroll movement
                if abs(offset) > 1 {
                    isScrolling = true
                    scrollTask = Task {
                        try? await Task.sleep(nanoseconds: 150_000_000) // 150ms debounce
                        if !Task.isCancelled {
                            isScrolling = false
                        }
                    }
                } else if wasScrolling {
                    // User stopped scrolling, restore shadow after brief delay
                    scrollTask = Task {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms delay
                        if !Task.isCancelled {
                            isScrolling = false
                        }
                    }
                }
            }
    }
}

extension View {
    /// Apply scroll-aware shadow that defers heavy rendering during scroll
    func scrollAwareShadow(
        opacity: Double = 0.18,
        radius: CGFloat = 24,
        y: CGFloat = 8
    ) -> some View {
        modifier(ScrollAwareShadow(
            shadowOpacity: opacity,
            shadowRadius: radius,
            shadowY: y
        ))
    }
}

/// Preference key to track scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// ScrollView wrapper that tracks scroll position for performance optimizations
struct PerformanceScrollView<Content: View>: View {
    let content: () -> Content
    let axes: Axis.Set
    let showsIndicators: Bool
    
    @State private var scrollOffset: CGFloat = 0
    
    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                    }
                )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            scrollOffset = offset
        }
    }
}
