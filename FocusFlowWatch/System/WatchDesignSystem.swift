import SwiftUI

/// Watch Design System - Spacing system optimized for Apple Watch
/// Agent 14: Enhanced spacing for better visual comfort on Watch
/// Matches main app DesignSystem spacing values for consistency
enum WatchDesignSystem {
    
    // MARK: - Spacing Scale (Optimized for Watch with visual comfort)
    
    enum Spacing {
        // Core spacing scale - optimized for Watch screens
        static let xs: CGFloat = 8      // Tight spacing, icon padding
        static let sm: CGFloat = 16     // Standard spacing
        static let md: CGFloat = 24     // Comfortable spacing
        static let lg: CGFloat = 32     // Generous spacing
        
        // Fine-tuned spacing for visual harmony
        static let tight: CGFloat = 4   // Very tight (icons, badges)
        static let comfortable: CGFloat = 12  // Comfortable medium-tight spacing
        static let relaxed: CGFloat = 20  // Relaxed medium spacing
        
        // Semantic spacing (optimized for Watch)
        static let cardPadding: CGFloat = 16      // Cards - comfortable for Watch
        static let regularCardPadding: CGFloat = 12  // Regular cards - slightly more compact
        static let compactCardPadding: CGFloat = 8   // Compact cards - tight for Watch
        static let sectionSpacing: CGFloat = 24     // Between sections - comfortable
        static let gridSpacing: CGFloat = 12        // Grid layouts - comfortable
        static let listItemSpacing: CGFloat = 8     // List items - tight for Watch
        static let buttonSpacing: CGFloat = 8       // Between buttons - comfortable
        static let textSpacing: CGFloat = 4        // Between text elements - tight
        static let iconSpacing: CGFloat = 6        // Icon to text - comfortable
        static let statBoxSpacing: CGFloat = 12    // Between stat boxes
        
        // Content spacing
        static let contentPadding: CGFloat = 12    // Content area padding
        static let screenEdgePadding: CGFloat = 8  // Screen edge padding (Watch)
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 16
        static let button: CGFloat = 12
    }
}

// MARK: - Spacing Extensions for Watch

extension View {
    /// Apply card padding for Watch (comfortable)
    func watchCardPadding() -> some View {
        self.padding(WatchDesignSystem.Spacing.cardPadding)
    }
    
    /// Apply regular card padding for Watch
    func watchRegularCardPadding() -> some View {
        self.padding(WatchDesignSystem.Spacing.regularCardPadding)
    }
    
    /// Apply compact card padding for Watch
    func watchCompactCardPadding() -> some View {
        self.padding(WatchDesignSystem.Spacing.compactCardPadding)
    }
    
    /// Apply screen edge padding for Watch
    func watchScreenEdgePadding() -> some View {
        self.padding(.horizontal, WatchDesignSystem.Spacing.screenEdgePadding)
            .padding(.vertical, WatchDesignSystem.Spacing.comfortable)
    }
}

