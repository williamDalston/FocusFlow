import SwiftUI

/// Design System - Comprehensive spacing, sizing, and visual constants
/// Ensures consistent spacing, sizing, and visual elements throughout the app
enum DesignSystem {
    
    // MARK: - Spacing Scale (Refined 8pt grid system for elegance)
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let huge: CGFloat = 64
        
        // Semantic spacing (refined for more breathing room)
        static let cardPadding: CGFloat = 24  // Increased from 20 for more elegant spacing
        static let sectionSpacing: CGFloat = 32  // Increased from 24 for better hierarchy
        static let sectionSpacingIPad: CGFloat = 40  // Increased from 32 for iPad elegance
        static let gridSpacing: CGFloat = 16  // Increased from 12 for better visual separation
        static let listItemSpacing: CGFloat = 12  // Increased from 8 for better readability
        static let formFieldSpacing: CGFloat = 20  // Increased from 16 for clearer form hierarchy
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
    
    // MARK: - Border Widths (Refined for Visual Precision)
    
    enum Border {
        static let hairline: CGFloat = 0.33
        static let subtle: CGFloat = 0.5
        static let standard: CGFloat = 1.0
        static let emphasis: CGFloat = 1.5
        static let strong: CGFloat = 2.0
        static let bold: CGFloat = 2.5
        
        // Semantic borders
        static let card: CGFloat = 1.0
        static let button: CGFloat = 1.0
        static let divider: CGFloat = 0.5
    }
    
    // MARK: - Shadow System (Refined for Elegant Depth)
    
    enum Shadow {
        // Base shadows with refined, softer depth
        static let small: (radius: CGFloat, y: CGFloat) = (8, 4)  // Softer than before
        static let medium: (radius: CGFloat, y: CGFloat) = (16, 8)  // Softer, more elegant
        static let large: (radius: CGFloat, y: CGFloat) = (24, 12)  // Refined for sophistication
        static let xlarge: (radius: CGFloat, y: CGFloat) = (32, 16)
        static let xxlarge: (radius: CGFloat, y: CGFloat) = (40, 20)  // Increased for more presence
        
        // Semantic shadows with refined multi-layer depth
        static let card: (radius: CGFloat, y: CGFloat) = (32, 16)  // Softer, more elegant
        static let button: (radius: CGFloat, y: CGFloat) = (28, 14)  // Refined for sophistication
        static let elevated: (radius: CGFloat, y: CGFloat) = (24, 12)  // Softer elevation
        
        // Pressed/interactive states (refined for subtle feedback)
        static let pressed: (radius: CGFloat, y: CGFloat) = (10, 5)  // Slightly softer
        
        // Soft shadows for subtle elevation (refined)
        static let soft: (radius: CGFloat, y: CGFloat) = (20, 10)  // More refined
        static let verySoft: (radius: CGFloat, y: CGFloat) = (12, 6)  // Softer, more elegant
    }
    
    // MARK: - Opacity Scale (Refined for Sophisticated Elegance)
    
    enum Opacity {
        // Base opacity scale (refined for subtlety and sophistication)
        static let subtle: Double = 0.12  // More subtle than before
        static let light: Double = 0.20  // Refined for elegance
        static let medium: Double = 0.40  // Softer for sophistication
        static let strong: Double = 0.60  // Refined
        static let veryStrong: Double = 0.72  // More subtle
        static let almostOpaque: Double = 0.90  // Refined
        
        // Semantic opacities (refined for better visual hierarchy)
        static let disabled: Double = 0.38  // Slightly more subtle
        static let overlay: Double = 0.70  // Softer overlay
        static let stroke: Double = 0.25  // More elegant stroke
        static let strokeInner: Double = 0.65  // Refined inner stroke
        static let glow: Double = 0.20  // More subtle glow
        
        // Premium effects (refined for sophistication)
        static let highlight: Double = 0.10  // More subtle highlight
        static let shimmer: Double = 0.30  // Refined shimmer
        static let borderSubtle: Double = 0.18  // More elegant border
        static let borderStrong: Double = 0.45  // Refined strong border
    }
    
    // MARK: - Typography System (Refined for Elegance)
    
    enum Typography {
        // Line heights (refined for better readability and elegance)
        static let titleLineHeight: CGFloat = 1.25  // Increased from 1.2 for more breathing room
        static let bodyLineHeight: CGFloat = 1.5  // Increased from 1.4 for better readability
        static let captionLineHeight: CGFloat = 1.35  // Increased from 1.3 for clarity
        
        // Letter spacing (refined for sophistication)
        static let uppercaseTracking: CGFloat = 0.6  // Slightly increased for elegance
        static let normalTracking: CGFloat = 0
        
        // Font weights (refined for visual hierarchy)
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

// MARK: - Shadow Extensions (Multi-Layer Premium Shadows)

extension View {
    /// Apply premium multi-layer card shadow with depth
    func cardShadow() -> some View {
        self
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.2), 
                   radius: DesignSystem.Shadow.card.radius, 
                   y: DesignSystem.Shadow.card.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light), 
                   radius: DesignSystem.Shadow.medium.radius, 
                   y: DesignSystem.Shadow.medium.y)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle), 
                   radius: DesignSystem.Shadow.soft.radius, 
                   y: DesignSystem.Shadow.soft.y)
    }
    
    /// Apply premium multi-layer button shadow
    func buttonShadow() -> some View {
        self
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.1), 
                   radius: DesignSystem.Shadow.button.radius, 
                   y: DesignSystem.Shadow.button.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light * 0.9), 
                   radius: DesignSystem.Shadow.medium.radius * 0.8, 
                   y: DesignSystem.Shadow.medium.y * 0.8)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 0.8), 
                   radius: DesignSystem.Shadow.soft.radius * 0.6, 
                   y: DesignSystem.Shadow.soft.y * 0.6)
    }
    
    /// Apply soft subtle shadow for elevated elements
    func softShadow() -> some View {
        self.shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle), 
                   radius: DesignSystem.Shadow.verySoft.radius, 
                   y: DesignSystem.Shadow.verySoft.y)
    }
    
    /// Apply pressed state shadow
    func pressedShadow() -> some View {
        self.shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.light), 
                   radius: DesignSystem.Shadow.pressed.radius, 
                   y: DesignSystem.Shadow.pressed.y)
    }
}

