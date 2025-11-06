import Foundation
import SwiftUI

/// Agent 7: Productivity Tips Manager - Manages productivity tips shown during breaks
class ProductivityTipsManager {
    static let shared = ProductivityTipsManager()
    
    private let tips: [ProductivityTip] = [
        ProductivityTip(
            category: .focus,
            text: "Use the first Pomodoro of the day to tackle your most important task. Your willpower is highest in the morning.",
            icon: "sunrise.fill"
        ),
        ProductivityTip(
            category: .focus,
            text: "Eliminate distractions before starting. Put your phone in another room, close unnecessary browser tabs, and silence notifications.",
            icon: "bell.slash.fill"
        ),
        ProductivityTip(
            category: .focus,
            text: "If a distracting thought comes up during a focus session, write it down and handle it during your break.",
            icon: "pencil.and.list.clipboard"
        ),
        ProductivityTip(
            category: .focus,
            text: "Group similar tasks together. This helps maintain momentum and reduces context switching.",
            icon: "square.stack.3d.up.fill"
        ),
        ProductivityTip(
            category: .break,
            text: "During breaks, move your body. A short walk, stretch, or light movement boosts energy and creativity.",
            icon: "figure.walk"
        ),
        ProductivityTip(
            category: .break,
            text: "Look away from your screen during breaks. Your eyes need rest from the constant focus.",
            icon: "eye.fill"
        ),
        ProductivityTip(
            category: .break,
            text: "Stay hydrated. Drink water during breaks to maintain focus and energy levels.",
            icon: "drop.fill"
        ),
        ProductivityTip(
            category: .break,
            text: "Don't use breaks to catch up on other work. True breaks improve your next focus session.",
            icon: "pause.circle.fill"
        ),
        ProductivityTip(
            category: .planning,
            text: "Plan your tasks before starting. Knowing what you'll work on helps maintain focus.",
            icon: "list.bullet.clipboard.fill"
        ),
        ProductivityTip(
            category: .planning,
            text: "Review your progress at the end of the day. This helps you plan tomorrow more effectively.",
            icon: "chart.bar.fill"
        ),
        ProductivityTip(
            category: .planning,
            text: "Break large tasks into smaller, manageable chunks that fit into Pomodoro sessions.",
            icon: "scissors"
        ),
        ProductivityTip(
            category: .motivation,
            text: "Track your completed sessions. Seeing progress builds momentum and motivation.",
            icon: "flame.fill"
        ),
        ProductivityTip(
            category: .motivation,
            text: "Celebrate small wins. Each completed Pomodoro is a step toward your goals.",
            icon: "star.fill"
        ),
        ProductivityTip(
            category: .motivation,
            text: "Be flexible. If 25 minutes feels too long or short, adjust to what works for you.",
            icon: "slider.horizontal.3"
        ),
        ProductivityTip(
            category: .health,
            text: "Take your breaks seriously. Regular breaks prevent burnout and maintain productivity.",
            icon: "heart.fill"
        ),
        ProductivityTip(
            category: .health,
            text: "Practice good posture. Set up your workspace ergonomically to avoid fatigue.",
            icon: "figure.stand"
        ),
        ProductivityTip(
            category: .health,
            text: "Eat regular, healthy meals. Your brain needs fuel to maintain focus throughout the day.",
            icon: "fork.knife"
        )
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get a random tip for a specific category
    func randomTip(for category: ProductivityTipCategory? = nil) -> ProductivityTip {
        let filteredTips = category == nil ? tips : tips.filter { $0.category == category }
        return filteredTips.randomElement() ?? tips[0]
    }
    
    /// Get tips for a specific category
    func tips(for category: ProductivityTipCategory) -> [ProductivityTip] {
        tips.filter { $0.category == category }
    }
    
    /// Get a tip for break time
    func breakTip() -> ProductivityTip {
        randomTip(for: .break)
    }
    
    /// Get a tip for focus time
    func focusTip() -> ProductivityTip {
        randomTip(for: .focus)
    }
    
    /// Get all tips
    func allTips() -> [ProductivityTip] {
        tips
    }
}

// MARK: - Productivity Tip

struct ProductivityTip: Identifiable {
    let id = UUID()
    let category: ProductivityTipCategory
    let text: String
    let icon: String
}

// MARK: - Productivity Tip Category

enum ProductivityTipCategory: String, CaseIterable {
    case focus = "Focus"
    case `break` = "Break"
    case planning = "Planning"
    case motivation = "Motivation"
    case health = "Health"
    
    var displayName: String {
        rawValue
    }
    
    var color: Color {
        switch self {
        case .focus:
            return Theme.accentA
        case .break:
            return Theme.accentB
        case .planning:
            return Theme.accentC
        case .motivation:
            return Theme.accentA
        case .health:
            return Theme.accentB
        }
    }
}

