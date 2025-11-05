import Foundation
@testable import SevenMinuteWorkout

/// Mock implementation of HapticFeedbackProvider for testing
final class MockHapticFeedback: HapticFeedbackProvider {
    private(set) var tapCallCount = 0
    private(set) var gentleCallCount = 0
    private(set) var successCallCount = 0
    
    func tap() {
        tapCallCount += 1
    }
    
    func gentle() {
        gentleCallCount += 1
    }
    
    func success() {
        successCallCount += 1
    }
    
    func reset() {
        tapCallCount = 0
        gentleCallCount = 0
        successCallCount = 0
    }
}

