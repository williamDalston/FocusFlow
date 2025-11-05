import SwiftUI

/// Design System - Comprehensive spacing, sizing, and visual constants
/// Ensures consistent spacing, sizing, and visual elements throughout the app
enum DesignSystem {
    
    // MARK: - Spacing Scale (8pt grid system)
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let huge: CGFloat = 64
        
        // Semantic spacing
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let sectionSpacingIPad: CGFloat = 32
        static let gridSpacing: CGFloat = 12
        static let listItemSpacing: CGFloat = 8
        static let formFieldSpacing: CGFloat = 16
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
        static let circular: CGFloat = 9999
        
        // Semantic radii
        static let card: CGFloat = 20
        static let button: CGFloat = 14
        static let statBox: CGFloat = 12
        static let badge: CGFloat = 8
    }
    
    // MARK: - Border Widths
    
    enum Border {
        static let subtle: CGFloat = 0.5
        static let standard: CGFloat = 1.0
        static let emphasis: CGFloat = 1.5
        static let strong: CGFloat = 2.0
    }
    
    // MARK: - Shadow System
    
    enum Shadow {
        static let small: (radius: CGFloat, y: CGFloat) = (4, 2)
        static let medium: (radius: CGFloat, y: CGFloat) = (8, 4)
        static let large: (radius: CGFloat, y: CGFloat) = (12, 6)
        static let xlarge: (radius: CGFloat, y: CGFloat) = (20, 10)
        static let xxlarge: (radius: CGFloat, y: CGFloat) = (25, 12)
        
        static let card: (radius: CGFloat, y: CGFloat) = (25, 12)
        static let button: (radius: CGFloat, y: CGFloat) = (22, 12)
        static let elevated: (radius: CGFloat, y: CGFloat) = (18, 10)
    }
    
    // MARK: - Opacity Scale
    
    enum Opacity {
        static let subtle: Double = 0.2
        static let light: Double = 0.3
        static let medium: Double = 0.5
        static let strong: Double = 0.7
        static let veryStrong: Double = 0.8
        static let almostOpaque: Double = 0.95
        
        // Semantic opacities
        static let disabled: Double = 0.5
        static let overlay: Double = 0.7
        static let stroke: Double = 0.35
        static let strokeInner: Double = 0.75
        static let glow: Double = 0.3
    }
    
    // MARK: - Typography System
    
    enum Typography {
        // Line heights (relative to font size)
        static let titleLineHeight: CGFloat = 1.2
        static let bodyLineHeight: CGFloat = 1.4
        static let captionLineHeight: CGFloat = 1.3
        
        // Letter spacing
        static let uppercaseTracking: CGFloat = 0.5
        static let normalTracking: CGFloat = 0
        
        // Font weights
        static let titleWeight: Font.Weight = .bold
        static let headlineWeight: Font.Weight = .semibold
        static let bodyWeight: Font.Weight = .regular
        static let captionWeight: Font.Weight = .medium
    }
    
    // MARK: - Icon Sizes
    
    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
        static let xxlarge: CGFloat = 48
        static let huge: CGFloat = 64
        
        // Semantic sizes
        static let statBox: CGFloat = 24
        static let button: CGFloat = 20
        static let card: CGFloat = 48
    }
    
    // MARK: - Button Sizes
    
    enum ButtonSize {
        static let small: (height: CGFloat, padding: CGFloat) = (44, 12)
        static let standard: (height: CGFloat, padding: CGFloat) = (50, 14)
        static let large: (height: CGFloat, padding: CGFloat) = (56, 16)
    }
    
    // MARK: - Touch Targets (Accessibility)
    
    enum TouchTarget {
        static let minimum: CGFloat = 44
        static let comfortable: CGFloat = 48
        static let spacious: CGFloat = 56
    }
    
    // MARK: - Animation Durations
    
    enum AnimationDuration {
        static let instant: Double = 0.1
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let smooth: Double = 0.4
        static let slow: Double = 0.5
        static let verySlow: Double = 0.6
    }
    
    // MARK: - Screen Sizing
    
    enum Screen {
        static let maxContentWidth: CGFloat = 800
        static let sidePadding: CGFloat = 16
        static let sidePaddingIPad: CGFloat = 32
        static let topPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 32
    }
}

// MARK: - Spacing Extensions

extension View {
    /// Apply standard spacing between sections
    func sectionSpacing() -> some View {
        self.padding(.vertical, DesignSystem.Spacing.sectionSpacing)
    }
    
    /// Apply standard card padding
    func cardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }
    
    /// Apply standard content padding
    func contentPadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
    }
}

// MARK: - Corner Radius Extensions

extension View {
    /// Apply standard card corner radius
    func cardCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous))
    }
    
    /// Apply standard button corner radius
    func buttonCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous))
    }
}

// MARK: - Shadow Extensions

extension View {
    /// Apply standard card shadow
    func cardShadow() -> some View {
        self.shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                   radius: DesignSystem.Shadow.card.radius, 
                   y: DesignSystem.Shadow.card.y)
    }
    
    /// Apply standard button shadow
    func buttonShadow() -> some View {
        self.shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                   radius: DesignSystem.Shadow.button.radius, 
                   y: DesignSystem.Shadow.button.y)
    }
}

