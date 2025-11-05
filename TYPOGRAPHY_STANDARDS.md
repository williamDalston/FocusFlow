# 📝 Typography Standards - Ritual7

**Date:** 2024-12-19  
**Status:** Standardized across all sections

---

## Typography Hierarchy

### Section Headers
**Use:** `Theme.headline` (17pt, Semibold)  
**Examples:**
- "Your Progress"
- "Insights"
- "Goals"
- "Custom Workouts"
- "Duration Settings"
- "Quick Settings"

### Card Titles
**Use:** `Theme.title3` (20pt, Semibold) or `Theme.headline` (17pt, Semibold)  
**Examples:**
- Exercise card titles
- Preset names
- Achievement titles

### Large Titles
**Use:** `Theme.title2` (22pt, Bold) or `Theme.title` (28pt, Bold)  
**Examples:**
- Main app title ("Ritual7")
- Achievement celebration titles
- Hero card titles

### Body Text
**Use:** `Theme.body` (17pt, Regular) or `Theme.subheadline` (15pt, Regular)  
**Examples:**
- Exercise descriptions
- Card descriptions
- Settings descriptions
- Toggle labels

### Captions & Labels
**Use:** `Theme.caption` (12pt, Medium) or `Theme.caption2` (11pt, Medium)  
**Examples:**
- Time labels
- Stat labels
- Secondary information
- Metadata

### Button Text
**Primary Buttons:** `Theme.headline` (17pt, Semibold)  
**Secondary Buttons:** `Theme.subheadline` (15pt, Medium)  
**Examples:**
- "Start Workout" → `Theme.headline`
- "Customize", "History", "Exercises" → `Theme.subheadline.weight(.medium)`

---

## Consistency Rules

1. **All section headers** → `Theme.headline`
2. **All card titles** → `Theme.title3` or `Theme.headline`
3. **All body text** → `Theme.body` or `Theme.subheadline`
4. **All captions** → `Theme.caption` or `Theme.caption2`
5. **All buttons** → `Theme.headline` (primary) or `Theme.subheadline.weight(.medium)` (secondary)

---

## ✅ Standardized Files

- ✅ `WorkoutContentView.swift` - All fonts use Theme constants
- ✅ `WorkoutCustomizationView.swift` - All fonts use Theme constants
- ✅ `WorkoutHistoryView.swift` - All fonts use Theme constants
- ✅ `SettingsView.swift` - All fonts use Theme constants
- ✅ `RootView.swift` - All fonts use Theme constants
- ✅ `WorkoutTimerView.swift` - All fonts use Theme constants
- ✅ `ExerciseGuideView.swift` - All fonts use Theme constants

---

## Typography Scale Reference

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `Theme.largeTitle` | 34pt | Bold | Main app titles (iPad) |
| `Theme.title` | 28pt | Bold | Main titles, hero headings |
| `Theme.title2` | 22pt | Bold | Subsection titles, stats |
| `Theme.title3` | 20pt | Semibold | Card titles, icons |
| `Theme.headline` | 17pt | Semibold | Section headers, primary buttons |
| `Theme.body` | 17pt | Regular | Body text, descriptions |
| `Theme.subheadline` | 15pt | Regular | Secondary text, button labels |
| `Theme.caption` | 12pt | Medium | Labels, metadata |
| `Theme.caption2` | 11pt | Medium | Smallest labels |
| `Theme.footnote` | 13pt | Regular | Footnotes, timestamps |

---

**Last Updated:** 2024-12-19


