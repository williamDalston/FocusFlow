import SwiftUI

/// Animated counter that counts up to a target value
struct AnimatedCounter: View {
    let value: Int
    let duration: Double
    let font: Font
    let foregroundStyle: AnyShapeStyle
    
    @State private var displayValue: Int = 0
    
    init(
        value: Int,
        duration: Double = 1.0,
        font: Font = Theme.title2,
        foregroundStyle: AnyShapeStyle = AnyShapeStyle(Theme.textPrimary)
    ) {
        self.value = value
        self.duration = duration
        self.font = font
        self.foregroundStyle = foregroundStyle
    }
    
    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundStyle(foregroundStyle)
            .monospacedDigit()
            .contentTransition(.numericText())
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { newValue in
                animateToValue(from: displayValue, to: newValue)
            }
    }
    
    private func animateToValue(from start: Int = 0, to end: Int? = nil) {
        let target = end ?? value
        let steps = max(abs(target - start), 1)
        let stepDuration = duration / Double(steps)
        
        displayValue = start
        
        guard steps > 0 else { return }
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                let increment = target > start ? 1 : -1
                displayValue = min(max(start + (increment * step), min(start, target)), max(start, target))
                
                if step == steps {
                    displayValue = target
                }
            }
        }
    }
}

/// Animated counter with gradient styling
struct AnimatedGradientCounter: View {
    let value: Int
    let duration: Double
    let font: Font
    let gradient: LinearGradient
    
    @State private var displayValue: Int = 0
    
    init(
        value: Int,
        duration: Double = 1.0,
        font: Font = Theme.title2,
        gradient: LinearGradient = LinearGradient(
            colors: [Theme.accentA, Theme.accentB],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    ) {
        self.value = value
        self.duration = duration
        self.font = font
        self.gradient = gradient
    }
    
    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundStyle(gradient)
            .monospacedDigit()
            .contentTransition(.numericText())
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { newValue in
                animateToValue(from: displayValue, to: newValue)
            }
    }
    
    private func animateToValue(from start: Int = 0, to end: Int? = nil) {
        let target = end ?? value
        let steps = max(abs(target - start), 1)
        let stepDuration = duration / Double(steps)
        
        displayValue = start
        
        guard steps > 0 else { return }
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                let increment = target > start ? 1 : -1
                displayValue = min(max(start + (increment * step), min(start, target)), max(start, target))
                
                if step == steps {
                    displayValue = target
                }
            }
        }
    }
}

