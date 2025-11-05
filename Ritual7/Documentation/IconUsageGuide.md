# 🎯 Icon Usage Guide

**Last Updated:** 2024-12-19  
**Agent:** 31 - Component Consistency Audit

---

## Overview

This guide provides comprehensive guidelines for using icons consistently throughout the Ritual7 app. All icons should use design system constants for sizing and weights.

---

## Icon Sizes

### Standard Sizes
Use `DesignSystem.IconSize` constants for all icon sizes:

| Size | Constant | Value | Usage |
|------|----------|-------|-------|
| Small | `IconSize.small` | 16pt | Inline icons, badges, small buttons |
| Medium | `IconSize.medium` | 20pt | Standard buttons, list items |
| Large | `IconSize.large` | 24pt | Stat boxes, card headers |
| XLarge | `IconSize.xlarge` | 32pt | Large cards, prominent elements |
| XXLarge | `IconSize.xxlarge` | 48pt | Hero sections, large cards |
| Huge | `IconSize.huge` | 64pt | Hero icons, landing screens |

### Semantic Sizes
Use semantic sizes when available:

| Semantic | Constant | Value | Usage |
|----------|----------|-------|-------|
| Button | `IconSize.button` | 20pt | Button icons (standard) |
| Stat Box | `IconSize.statBox` | 24pt | Stat box icons |
| Card | `IconSize.card` | 48pt | Large card icons |

---

## Icon Weights

### Standard Weights
Use `DesignSystem.IconWeight` constants for all icon weights:

| Weight | Constant | Value | Usage |
|--------|----------|-------|-------|
| Standard | `IconWeight.standard` | `.medium` | **Default** - Use for most icons |
| Emphasis | `IconWeight.emphasis` | `.semibold` | Secondary emphasis, slightly prominent |
| Strong | `IconWeight.strong` | `.bold` | Primary emphasis, hero icons, primary actions |

### When to Use Each Weight

**Standard (`.medium`)** - Use for:
- ✅ Most icons in the app
- ✅ List items
- ✅ Secondary buttons
- ✅ Card icons
- ✅ Navigation icons
- ✅ Stat box icons

**Emphasis (`.semibold`)** - Use for:
- ✅ Important secondary actions
- ✅ Toast notification icons
- ✅ Alert icons
- ✅ When you need slightly more visual weight than standard

**Strong (`.bold`)** - Use for:
- ✅ Primary action icons (e.g., "Start Workout" play button)
- ✅ Hero section icons
- ✅ Landing screen icons
- ✅ Critical call-to-action icons
- ⚠️ **Use sparingly** - Only for maximum emphasis

---

## Usage Examples

### ✅ Correct Usage

```swift
// Standard button icon
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.button, weight: DesignSystem.IconWeight.standard))

// Primary action icon (hero)
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.strong))

// Stat box icon
Image(systemName: "flame.fill")
    .font(.system(size: DesignSystem.IconSize.statBox, weight: DesignSystem.IconWeight.standard))

// Hero icon
Image(systemName: "figure.run")
    .font(.system(size: DesignSystem.IconSize.huge, weight: DesignSystem.IconWeight.strong))
```

### ❌ Incorrect Usage

```swift
// ❌ Hardcoded size and weight
Image(systemName: "play.fill")
    .font(.system(size: 20, weight: .bold))

// ❌ Missing weight specification
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.medium))

// ❌ Using .bold for everything
Image(systemName: "settings")
    .font(.system(size: DesignSystem.IconSize.medium, weight: .bold))
```

---

## Common Patterns

### Button Icons
```swift
// Primary button
Image(systemName: "play.fill")
    .font(.system(size: DesignSystem.IconSize.button, weight: DesignSystem.IconWeight.strong))

// Secondary button
Image(systemName: "gear")
    .font(.system(size: DesignSystem.IconSize.button, weight: DesignSystem.IconWeight.standard))
```

### List Item Icons
```swift
Image(systemName: "checkmark.circle.fill")
    .font(.system(size: DesignSystem.IconSize.medium, weight: DesignSystem.IconWeight.standard))
```

### Stat Box Icons
```swift
Image(systemName: "flame.fill")
    .font(.system(size: DesignSystem.IconSize.statBox, weight: DesignSystem.IconWeight.standard))
    .foregroundStyle(Theme.accentA)
```

### Hero Icons
```swift
Image(systemName: "figure.run")
    .font(.system(size: DesignSystem.IconSize.huge, weight: DesignSystem.IconWeight.strong))
    .foregroundStyle(
        LinearGradient(
            colors: [Theme.accentA, Theme.accentB],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
```

---

## Accessibility

### Color Contrast
- Ensure icons meet WCAG AA contrast requirements (4.5:1)
- Use `Theme` colors for consistent contrast
- Test icons on both light and dark backgrounds

### Touch Targets
- Icon buttons should have minimum 44x44pt touch targets
- Use padding around icons to meet touch target requirements
- Use `DesignSystem.TouchTarget.minimum` for minimum touch areas

### VoiceOver Labels
- Always provide `.accessibilityLabel()` for icon-only buttons
- Use descriptive labels (e.g., "Start Workout" not "Play button")

```swift
Button {
    startWorkout()
} label: {
    Image(systemName: "play.fill")
        .font(.system(size: DesignSystem.IconSize.button, weight: DesignSystem.IconWeight.strong))
}
.accessibilityLabel("Start Workout")
.accessibilityHint("Double tap to begin your 7-minute workout")
```

---

## Best Practices

### ✅ DO
- Use `DesignSystem.IconSize` constants for all icon sizes
- Use `DesignSystem.IconWeight.standard` (.medium) for most icons
- Use semantic sizes when available (e.g., `IconSize.button`)
- Provide accessibility labels for icon-only buttons
- Ensure proper touch target sizes (44x44pt minimum)
- Use Theme colors for consistent styling

### ❌ DON'T
- Don't use hardcoded sizes (e.g., `size: 20`)
- Don't use `.bold` for all icons (use `.medium` for most)
- Don't skip accessibility labels
- Don't make touch targets smaller than 44x44pt
- Don't use hardcoded colors (use Theme colors)

---

## Migration Checklist

When updating existing icons:

- [ ] Replace hardcoded sizes with `DesignSystem.IconSize` constants
- [ ] Replace hardcoded weights with `DesignSystem.IconWeight` constants
- [ ] Use `.medium` (standard) for most icons
- [ ] Use `.bold` (strong) only for primary actions and hero icons
- [ ] Add accessibility labels where missing
- [ ] Verify touch targets meet 44x44pt minimum
- [ ] Test contrast on both light and dark backgrounds

---

## Related Documentation

- [DesignSystem.md](./DesignSystem.md) - Complete design system documentation
- [ComponentShowcase.swift](./ComponentShowcase.swift) - Interactive component showcase

---

**Last Updated:** 2024-12-19  
**Maintained by:** Agent 31 - Component Consistency Audit
