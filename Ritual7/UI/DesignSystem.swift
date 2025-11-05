import SwiftUI

/// Design System - Comprehensive spacing, sizing, and visual constants
/// Ensures consistent spacing, sizing, and visual elements throughout the app
enum DesignSystem {
    
    // MARK: - Spacing Scale (Strict 8pt grid system per Apple HIG)
    
    enum Spacing {
        // Strict 8pt grid: 8, 16, 24, 32
        static let xs: CGFloat = 8
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        
        // Legacy spacing (kept for backward compatibility, will migrate)
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let huge: CGFloat = 64
        
        // Semantic spacing (8pt grid aligned)
        static let cardPadding: CGFloat = 24  // Hero cards (8pt grid: 24 = 3×8)
        static let regularCardPadding: CGFloat = 16  // Regular cards (8pt grid: 16 = 2×8)
        static let sectionSpacing: CGFloat = 32  // Spacing between major sections (8pt grid: 32 = 4×8)
        static let sectionSpacingIPad: CGFloat = 32  // Same as iPhone (8pt grid aligned)
        static let gridSpacing: CGFloat = 16  // Grid spacing (8pt grid: 16 = 2×8)
        static let listItemSpacing: CGFloat = 16  // List items (8pt grid: 16 = 2×8)
        static let formFieldSpacing: CGFloat = 24  // Form fields (8pt grid: 24 = 3×8)
    }
    
    // MARK: - Corner Radius (Apple HIG aligned)
    
    enum CornerRadius {
        // Base radii (8pt grid aligned where possible)
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
        static let circular: CGFloat = 9999
        
        // Semantic radii (per Apple HIG + fitness app patterns)
        static let card: CGFloat = 24  // Large cards (reduced from 28 for less "marshmallow" feel)
        static let button: CGFloat = 16  // Buttons/chips (reduced from 18)
        static let statBox: CGFloat = 16  // Stat boxes
        static let badge: CGFloat = 8  // Badges (reduced from 10)
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
    
    // MARK: - Shadow System (Apple HIG aligned - single token per spec)
    
    enum Shadow {
        // Base shadows (8pt grid aligned)
        static let small: (radius: CGFloat, y: CGFloat) = (8, 4)
        static let medium: (radius: CGFloat, y: CGFloat) = (16, 8)
        static let large: (radius: CGFloat, y: CGFloat) = (24, 12)
        static let xlarge: (radius: CGFloat, y: CGFloat) = (32, 16)
        static let xxlarge: (radius: CGFloat, y: CGFloat) = (40, 20)
        
        // Semantic shadows (per Apple HIG + fitness app patterns)
        // Primary token: rgba(0,0,0,0.18), y:8, blur:24
        static let card: (radius: CGFloat, y: CGFloat, opacity: Double) = (24, 8, 0.18)  // Single token per spec
        static let button: (radius: CGFloat, y: CGFloat, opacity: Double) = (24, 8, 0.18)  // Same token
        static let elevated: (radius: CGFloat, y: CGFloat) = (24, 8)  // Simplified
        static let floating: (radius: CGFloat, y: CGFloat) = (24, 8)  // Simplified
        static let modal: (radius: CGFloat, y: CGFloat) = (24, 8)  // Simplified
        
        // Pressed/interactive states
        static let pressed: (radius: CGFloat, y: CGFloat) = (8, 4)
        
        // Soft shadows for subtle elevation
        static let soft: (radius: CGFloat, y: CGFloat) = (16, 4)
        static let verySoft: (radius: CGFloat, y: CGFloat) = (8, 2)
        
        // Ambient shadows for depth (no Y offset)
        static let ambientSmall: CGFloat = 4
        static let ambientMedium: CGFloat = 8
        static let ambientLarge: CGFloat = 12
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
        
        // Special effects
        static let scrim: Double = 0.11  // Dark scrim for text readability (10-12% range)
    }
    
    // MARK: - Blur Radius
    
    enum BlurRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
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
    
    // MARK: - Icon Sizes & Weights
    
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
    
    enum IconWeight {
        // Standard icon weights (Agent 31: Standardized)
        // Most icons use medium weight
        static let standard: Font.Weight = .medium
        
        // Secondary emphasis (for slightly more prominent icons)
        static let emphasis: Font.Weight = .semibold
        
        // Primary emphasis (for hero icons, primary actions, hero metrics)
        static let strong: Font.Weight = .bold
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
    
    // MARK: - Visual Hierarchy (Agent 23)
    
    enum Hierarchy {
        // Font size hierarchy (increased differentiation)
        static let primaryTitle: CGFloat = 34  // Large title (increased from 28)
        static let secondaryTitle: CGFloat = 28  // Section title
        static let tertiaryTitle: CGFloat = 22  // Subsection title
        static let primaryBody: CGFloat = 17  // Primary body text
        static let secondaryBody: CGFloat = 15  // Secondary body text
        static let caption: CGFloat = 13  // Caption/helper text
        
        // Font weight hierarchy
        static let primaryWeight: Font.Weight = .bold  // Primary content
        static let secondaryWeight: Font.Weight = .semibold  // Secondary emphasis
        static let tertiaryWeight: Font.Weight = .medium  // Tertiary emphasis
        static let bodyWeight: Font.Weight = .regular  // Body text
        
        // Color saturation hierarchy (for importance indication)
        static let primarySaturation: Double = 1.0  // Full saturation for primary
        static let secondarySaturation: Double = 0.85  // Reduced for secondary
        static let tertiarySaturation: Double = 0.70  // Further reduced for tertiary
        
        // Opacity hierarchy (for secondary information)
        static let primaryOpacity: Double = 1.0  // Full opacity for primary
        static let secondaryOpacity: Double = 0.85  // Reduced for secondary
        static let tertiaryOpacity: Double = 0.65  // Further reduced for tertiary
        static let quaternaryOpacity: Double = 0.45  // Minimal for helper text
        
        // Section spacing hierarchy
        static let majorSectionSpacing: CGFloat = 40  // Between major sections (increased)
        static let minorSectionSpacing: CGFloat = 32  // Between minor sections
        static let subsectionSpacing: CGFloat = 24  // Within sections
    }
}

// MARK: - Spacing Extensions

extension View {
    /// Apply standard spacing between sections
    func sectionSpacing() -> some View {
        self.padding(.vertical, DesignSystem.Spacing.sectionSpacing)
    }
    
    /// Apply standard card padding (hero cards - 24pt)
    func cardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }
    
    /// Apply regular card padding (regular cards - 20pt)
    func regularCardPadding() -> some View {
        self.padding(DesignSystem.Spacing.regularCardPadding)
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

// MARK: - Border Extensions

extension View {
    /// Apply standard card border
    func cardBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.8),
                            Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: DesignSystem.Border.card
                )
        )
    }
    
    /// Apply subtle border
    func subtleBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .stroke(
                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle),
                    lineWidth: DesignSystem.Border.subtle
                )
        )
    }
    
    /// Apply enhanced multi-stop border
    func enhancedBorder() -> some View {
        self.overlay(
            EnhancedBorder(cornerRadius: DesignSystem.CornerRadius.card)
        )
    }
}

// MARK: - Shadow Extensions (Apple HIG aligned - single token per spec)

extension View {
    /// Apply card shadow - single token: rgba(0,0,0,0.18), y:8, blur:24
    /// Uses scroll-aware shadow for performance during scrolling
    func cardShadow() -> some View {
        self.scrollAwareShadow(
            opacity: DesignSystem.Shadow.card.opacity,
            radius: DesignSystem.Shadow.card.radius,
            y: DesignSystem.Shadow.card.y
        )
    }
    
    /// Apply button shadow - same token as card
    func buttonShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(DesignSystem.Shadow.button.opacity),
            radius: DesignSystem.Shadow.button.radius,
            x: 0,
            y: DesignSystem.Shadow.button.y
        )
    }
    
    /// Legacy multi-layer shadow (kept for backward compatibility)
    func legacyCardShadow() -> some View {
        self
            // Ambient shadow for base depth
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.8), 
                   radius: DesignSystem.Shadow.ambientMedium, 
                   x: 0, y: 0)
            // Primary directional shadow
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.2), 
                   radius: DesignSystem.Shadow.card.radius, 
                   y: DesignSystem.Shadow.card.y)
            // Secondary shadow for depth
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light), 
                   radius: DesignSystem.Shadow.medium.radius, 
                   y: DesignSystem.Shadow.medium.y)
            // Accent glow shadow
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle), 
                   radius: DesignSystem.Shadow.soft.radius, 
                   y: DesignSystem.Shadow.soft.y)
    }
    
    
    /// Apply elevated element shadow (for raised components)
    func elevatedShadow() -> some View {
        self
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                   radius: DesignSystem.Shadow.elevated.radius, 
                   y: DesignSystem.Shadow.elevated.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light * 0.8), 
                   radius: DesignSystem.Shadow.medium.radius * 0.7, 
                   y: DesignSystem.Shadow.medium.y * 0.7)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 0.6), 
                   radius: DesignSystem.Shadow.soft.radius * 0.5, 
                   y: DesignSystem.Shadow.soft.y * 0.5)
    }
    
    /// Apply floating element shadow (for floating UI elements)
    func floatingShadow() -> some View {
        self
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.3), 
                   radius: DesignSystem.Shadow.floating.radius, 
                   y: DesignSystem.Shadow.floating.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light * 1.1), 
                   radius: DesignSystem.Shadow.large.radius, 
                   y: DesignSystem.Shadow.large.y)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 1.0), 
                   radius: DesignSystem.Shadow.soft.radius, 
                   y: DesignSystem.Shadow.soft.y)
    }
    
    /// Apply modal shadow (for modal presentations)
    func modalShadow() -> some View {
        self
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.strong * 1.2), 
                   radius: DesignSystem.Shadow.modal.radius, 
                   y: DesignSystem.Shadow.modal.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.medium * 1.1), 
                   radius: DesignSystem.Shadow.xlarge.radius, 
                   y: DesignSystem.Shadow.xlarge.y)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.light * 0.8), 
                   radius: DesignSystem.Shadow.medium.radius, 
                   y: DesignSystem.Shadow.medium.y)
    }
    
    /// Apply soft subtle shadow for elevated elements
    func softShadow() -> some View {
        self.shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle), 
                   radius: DesignSystem.Shadow.verySoft.radius, 
                   y: DesignSystem.Shadow.verySoft.y)
    }
    
    /// Apply pressed state shadow (reduced shadow for pressed elements)
    func pressedShadow() -> some View {
        self.shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.light), 
                   radius: DesignSystem.Shadow.pressed.radius, 
                   y: DesignSystem.Shadow.pressed.y)
    }
}

