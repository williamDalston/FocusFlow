# 🎨 Design System Documentation

**Last Updated:** 2024-12-19  
**Version:** 1.0  
**Agent:** 31 - Component Consistency Audit

---

## 📋 Overview

This document provides comprehensive documentation for the Ritual7 design system. All design tokens are defined in `DesignSystem.swift` and should be used consistently throughout the app.

---

## 📏 Spacing Scale

### 8pt Grid System
All spacing values follow Apple's Human Interface Guidelines 8pt grid system:

| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.xs` | 8pt | Tight spacing, icon padding |
| `Spacing.sm` | 16pt | Standard spacing, card padding (regular) |
| `Spacing.md` | 24pt | Section spacing, hero card padding |
| `Spacing.lg` | 32pt | Major section spacing |

### Semantic Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.cardPadding` | 24pt | Hero cards, primary cards |
| `Spacing.regularCardPadding` | 16pt | Secondary cards, list items |
| `Spacing.sectionSpacing` | 32pt | Between major sections |
| `Spacing.gridSpacing` | 16pt | Grid layouts |
| `Spacing.listItemSpacing` | 16pt | List items |
| `Spacing.formFieldSpacing` | 24pt | Form fields |

### Usage Example
```swift
VStack(spacing: DesignSystem.Spacing.md) {
    // Content
}
.padding(DesignSystem.Spacing.cardPadding)
```

---

## 🔲 Corner Radius

### Base Radii
| Token | Value | Usage |
|-------|-------|-------|
| `CornerRadius.small` | 8pt | Small elements, badges |
| `CornerRadius.medium` | 16pt | Medium elements |
| `CornerRadius.large` | 24pt | Large elements |
| `CornerRadius.xlarge` | 24pt | Extra large elements |
| `CornerRadius.xxlarge` | 32pt | Very large elements |

### Semantic Radii
| Token | Value | Usage |
|-------|-------|-------|
| `CornerRadius.card` | 24pt | Cards, glass cards |
| `CornerRadius.button` | 16pt | Buttons, chips |
| `CornerRadius.statBox` | 16pt | Stat boxes |
| `CornerRadius.badge` | 8pt | Badges, tags |

### Usage Example
```swift
RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
```

---

## 🔳 Border Widths

| Token | Value | Usage |
|-------|-------|-------|
| `Border.hairline` | 0.33pt | Subtle borders, inner strokes |
| `Border.subtle` | 0.5pt | Light borders |
| `Border.standard` | 1.0pt | Standard borders |
| `Border.emphasis` | 1.5pt | Emphasized borders |
| `Border.strong` | 2.0pt | Strong borders |
| `Border.bold` | 2.5pt | Bold borders |

### Semantic Borders
| Token | Value | Usage |
|-------|-------|-------|
| `Border.card` | 1.0pt | Card borders |
| `Border.button` | 1.0pt | Button borders |
| `Border.divider` | 0.5pt | Dividers, separators |

### Usage Example
```swift
.stroke(Theme.accentA, lineWidth: DesignSystem.Border.standard)
```

---

## 🌑 Shadow System

### Base Shadows
All shadows use a single token per Apple HIG: `rgba(0,0,0,0.18)`, y:8, blur:24

| Token | Radius | Y Offset | Usage |
|-------|--------|----------|-------|
| `Shadow.small` | 8pt | 4pt | Small elevation |
| `Shadow.medium` | 16pt | 8pt | Medium elevation |
| `Shadow.large` | 24pt | 12pt | Large elevation |
| `Shadow.xlarge` | 32pt | 16pt | Extra large elevation |
| `Shadow.xxlarge` | 40pt | 20pt | Very large elevation |

### Semantic Shadows
| Token | Radius | Y Offset | Opacity | Usage |
|-------|--------|----------|---------|-------|
| `Shadow.card` | 24pt | 8pt | 0.18 | Cards |
| `Shadow.button` | 24pt | 8pt | 0.18 | Buttons |
| `Shadow.pressed` | 8pt | 4pt | - | Pressed state |

### Usage Example
```swift
.cardShadow()  // Uses DesignSystem.Shadow.card
```

---

## 👻 Opacity Scale

### Base Opacities
| Token | Value | Usage |
|-------|-------|-------|
| `Opacity.subtle` | 0.12 | Very subtle overlays |
| `Opacity.light` | 0.20 | Light overlays |
| `Opacity.medium` | 0.40 | Medium overlays |
| `Opacity.strong` | 0.60 | Strong overlays |
| `Opacity.veryStrong` | 0.72 | Very strong overlays |
| `Opacity.almostOpaque` | 0.90 | Almost opaque |

### Semantic Opacities
| Token | Value | Usage |
|-------|-------|-------|
| `Opacity.disabled` | 0.38 | Disabled elements |
| `Opacity.overlay` | 0.70 | Overlays |
| `Opacity.stroke` | 0.25 | Stroke overlays |
| `Opacity.borderSubtle` | 0.18 | Subtle borders |
| `Opacity.borderStrong` | 0.45 | Strong borders |
| `Opacity.glow` | 0.20 | Glow effects |
| `Opacity.highlight` | 0.10 | Highlights |

### Usage Example
```swift
Theme.accentA.opacity(DesignSystem.Opacity.subtle)
```

---

## 📝 Typography

### Font Weights
| Token | Value | Usage |
|-------|-------|-------|
| `Typography.titleWeight` | `.bold` | Primary titles |
| `Typography.headlineWeight` | `.semibold` | Headlines |
| `Typography.bodyWeight` | `.regular` | Body text |
| `Typography.captionWeight` | `.medium` | Captions |

### Line Heights
| Token | Value | Usage |
|-------|-------|-------|
| `Typography.titleLineHeight` | 1.25 | Titles |
| `Typography.bodyLineHeight` | 1.5 | Body text |
| `Typography.captionLineHeight` | 1.35 | Captions |

### Letter Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `Typography.uppercaseTracking` | 0.6pt | Uppercase text |
| `Typography.normalTracking` | 0pt | Normal text |

### Usage
Use `Theme` fonts instead of direct typography constants:
```swift
Text("Hello")
    .font(Theme.headline)
    .tracking(DesignSystem.Typography.uppercaseTracking)
```

---

## 🎯 Icon System

### Icon Sizes
| Token | Value | Usage |
|-------|-------|-------|
| `IconSize.small` | 16pt | Small icons, inline |
| `IconSize.medium` | 20pt | Medium icons, buttons |
| `IconSize.large` | 24pt | Large icons, stat boxes |
| `IconSize.xlarge` | 32pt | Extra large icons |
| `IconSize.xxlarge` | 48pt | Very large icons |
| `IconSize.huge` | 64pt | Hero icons |

### Semantic Icon Sizes
| Token | Value | Usage |
|-------|-------|-------|
| `IconSize.statBox` | 24pt | Stat box icons |
| `IconSize.button` | 20pt | Button icons |
| `IconSize.card` | 48pt | Card icons |

### Icon Weights
| Token | Weight | Usage |
|-------|--------|-------|
| `IconWeight.standard` | `.medium` | Default, most icons |
| `IconWeight.emphasis` | `.semibold` | Secondary emphasis |
| `IconWeight.strong` | `.bold` | Primary emphasis, hero icons, hero metrics |

### Usage Example
```swift
// Standard icon (most common)
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.standard))

// Emphasis icon (secondary emphasis)
Image(systemName: "star.fill")
    .font(.system(size: DesignSystem.IconSize.large, weight: DesignSystem.IconWeight.emphasis))

// Strong icon (hero metrics, primary actions)
Image(systemName: "flame.fill")
    .font(.system(size: DesignSystem.IconSize.huge, weight: DesignSystem.IconWeight.strong))
```

---

## 🔘 Button Sizes

| Token | Height | Padding | Usage |
|-------|--------|---------|-------|
| `ButtonSize.small` | 44pt | 12pt | Secondary buttons |
| `ButtonSize.standard` | 50pt | 14pt | Standard buttons |
| `ButtonSize.large` | 56pt | 16pt | Primary buttons |

### Usage Example
```swift
.frame(height: DesignSystem.ButtonSize.standard.height)
.padding(.vertical, DesignSystem.ButtonSize.standard.padding)
```

---

## 👆 Touch Targets

| Token | Value | Usage |
|-------|-------|-------|
| `TouchTarget.minimum` | 44pt | Minimum touch target (Apple HIG) |
| `TouchTarget.comfortable` | 48pt | Comfortable touch target |
| `TouchTarget.spacious` | 56pt | Spacious touch target |

### Usage Example
```swift
.frame(minWidth: DesignSystem.TouchTarget.minimum, 
       minHeight: DesignSystem.TouchTarget.minimum)
```

---

## ⏱️ Animation Durations

| Token | Value | Usage |
|-------|-------|-------|
| `AnimationDuration.instant` | 0.1s | Instant feedback |
| `AnimationDuration.quick` | 0.2s | Quick transitions |
| `AnimationDuration.standard` | 0.3s | Standard transitions |
| `AnimationDuration.smooth` | 0.4s | Smooth transitions |
| `AnimationDuration.slow` | 0.5s | Slow transitions |
| `AnimationDuration.verySlow` | 0.6s | Very slow transitions |

---

## 📱 Screen Sizing

| Token | Value | Usage |
|-------|-------|-------|
| `Screen.maxContentWidth` | 800pt | Maximum content width (iPad) |
| `Screen.sidePadding` | 16pt | Side padding (iPhone) |
| `Screen.sidePaddingIPad` | 32pt | Side padding (iPad) |
| `Screen.topPadding` | 24pt | Top padding |
| `Screen.bottomPadding` | 32pt | Bottom padding |

---

## 🎨 Visual Hierarchy

### Font Sizes
| Token | Value | Usage |
|-------|-------|-------|
| `Hierarchy.primaryTitle` | 34pt | Primary titles |
| `Hierarchy.secondaryTitle` | 28pt | Section titles |
| `Hierarchy.tertiaryTitle` | 22pt | Subsection titles |
| `Hierarchy.primaryBody` | 17pt | Primary body text |
| `Hierarchy.secondaryBody` | 15pt | Secondary body text |
| `Hierarchy.caption` | 13pt | Captions, helper text |

### Font Weights
| Token | Value | Usage |
|-------|-------|-------|
| `Hierarchy.primaryWeight` | `.bold` | Primary content |
| `Hierarchy.secondaryWeight` | `.semibold` | Secondary emphasis |
| `Hierarchy.tertiaryWeight` | `.medium` | Tertiary emphasis |
| `Hierarchy.bodyWeight` | `.regular` | Body text |

### Opacity Hierarchy
| Token | Value | Usage |
|-------|-------|-------|
| `Hierarchy.primaryOpacity` | 1.0 | Primary content |
| `Hierarchy.secondaryOpacity` | 0.85 | Secondary content |
| `Hierarchy.tertiaryOpacity` | 0.65 | Tertiary content |
| `Hierarchy.quaternaryOpacity` | 0.45 | Helper text |

### Section Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `Hierarchy.majorSectionSpacing` | 40pt | Between major sections |
| `Hierarchy.minorSectionSpacing` | 32pt | Between minor sections |
| `Hierarchy.subsectionSpacing` | 24pt | Within sections |

---

## 🌫️ Blur Radius

| Token | Value | Usage |
|-------|-------|-------|
| `BlurRadius.small` | 4pt | Small blur effects |
| `BlurRadius.medium` | 8pt | Medium blur effects |
| `BlurRadius.large` | 16pt | Large blur effects |
| `BlurRadius.xlarge` | 24pt | Extra large blur effects |

### Usage Example
```swift
.blur(radius: DesignSystem.BlurRadius.medium)
```

---

## ✅ Best Practices

### DO ✅
- Always use `DesignSystem` constants instead of hardcoded values
- Use semantic tokens when available (e.g., `Spacing.cardPadding` instead of `Spacing.md`)
- Follow the 8pt grid system for spacing
- Use `Theme` fonts for typography
- Use semantic icon sizes (e.g., `IconSize.button` for button icons)
- Use `.medium` weight for most icons, `.bold` only for emphasis

### DON'T ❌
- Don't use hardcoded numbers (e.g., `.padding(16)` instead of `.padding(DesignSystem.Spacing.sm)`)
- Don't use hardcoded corner radii (e.g., `.cornerRadius(12)` instead of `DesignSystem.CornerRadius.medium`)
- Don't use hardcoded font sizes (use `Theme` fonts)
- Don't use hardcoded opacity values (use `DesignSystem.Opacity` constants)
- Don't use `.bold` for all icons (use `.medium` for most)

---

## 🔍 Migration Guide

### Replacing Hardcoded Values

**Before:**
```swift
VStack(spacing: 16) {
    Text("Hello")
        .padding(24)
        .cornerRadius(12)
}
```

**After:**
```swift
VStack(spacing: DesignSystem.Spacing.sm) {
    Text("Hello")
        .padding(DesignSystem.Spacing.cardPadding)
        .clipShape(RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.medium, 
            style: .continuous
        ))
}
```

### Replacing Hardcoded Icon Sizes

**Before:**
```swift
Image(systemName: "play.fill")
    .font(.system(size: 20, weight: .bold))
```

**After:**
```swift
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.button, weight: .medium))
```

---

## 📚 Related Files

- `Ritual7/UI/DesignSystem.swift` - Design system implementation
- `Ritual7/UI/Theme.swift` - Typography and color system
- `Ritual7/UI/ButtonStyles.swift` - Button styles using design system
- `Ritual7/UI/GlassCard.swift` - Glass card component using design system

---

**Last Updated:** 2024-12-19  
**Maintained by:** Agent 31 - Component Consistency Audit

