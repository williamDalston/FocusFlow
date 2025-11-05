# 🎨 UX Redesign Plan - Apple HIG + Fitness App Patterns

**Date:** 2024-12-19  
**Status:** In Progress  
**North Star:** Make "start a 7-minute workout now" instant, obvious, and safe

---

## 📋 Information Architecture

### Current Structure
- ✅ Already has 3 tabs: Workout · History · Settings
- ✅ Simple structure maintained

### Changes Needed
- ❌ Remove "screen-inside-screen" framing (PopupContainer)
- ❌ Simplify home screen to single hero card
- ✅ Keep tabs as-is

---

## 🏠 Home Screen Redesign

### Current State
- Multiple cards: header, quickStartCard, dailyQuoteCard, statsGrid, achievements, etc.
- PopupContainer framing effect
- Complex layout with many sections

### Target State
**Single Hero Card:**
- Title: "7-Minute Workout"
- Subtitle: "12 moves · 7 min · No equipment"
- Primary CTA: "Start Workout" (full-width, 56-60pt tall)
- Metrics row (optional): "~84 kcal · ~7 min"
- Secondary actions bar (compact): Customize · Plan · History (icon + 1-2 word label)
- Streak tile: Small, glanceable (ring that fills toward next milestone)
- Exercises row: Icon, name, "30s" badge. Right alignment: "View All ›"

### Implementation Steps
1. Create new `HeroWorkoutCard` component
2. Remove PopupContainer from home
3. Simplify layout to single hero card + secondary actions
4. Move stats/achievements below fold or to separate sections

---

## 🎮 Player Redesign

### Current State
- Circular progress ring (single segment)
- Phase indicator text
- Controls scattered

### Target State
**Segmented Progress Ring:**
- 12 segments (one per exercise)
- Large remaining-seconds numeral inside ring
- State line under ring: "Now: Jumping Jacks (0:30)" + "Next: Wall Sit"
- Sticky control bar (bottom, ≥48pt hit targets): Pause/Resume (primary), Skip, Next, Volume

**Phase Colors:**
- Prepare = teal/blue
- Work = violet/indigo
- Rest = mint/green

**Cues:**
- Short haptic at phase change
- Voice cue "Next: Wall Sit" (toggle in player)

---

## 🎨 Visual System Tokens

### Current vs. Target

**Grid:**
- Current: Mixed spacing (4, 8, 12, 16, 24, 32, 48, 64)
- Target: Strict 8pt grid (8, 16, 24, 32)

**Corners:**
- Current: 28pt (card), 18pt (button), 16pt (statBox)
- Target: 24pt (large cards), 16pt (chips/buttons)

**Shadows:**
- Current: Multi-layer complex shadows
- Target: Single token: `rgba(0,0,0,0.18), y:8, blur:24`

**Glass:**
- Current: Multiple gradient overlays
- Target: Background blur + 12-16% white overlay (consistent)

**Contrast:**
- Current: Variable
- Target: Body text ≥ 4.5:1; 10-12% dark overlay behind hero text on gradients

---

## 📝 Microcopy Improvements

### Current → Target

1. "Start Workout" ✅ (already correct)
2. "Customize" → "Customize plan"
3. "Set your goals" → "Weekly & monthly goals"
4. Empty state: "No workouts yet. Start your first workout to build your streak."

---

## 🎭 Motion & Feedback

### Phase Transitions
- 180-220ms ease-in-out color crossfade
- Ring segment advance animation

### Haptics
- `.medium` at start/end of each phase
- `.heavy` on final exercise

### Voice
- 3-2-1 countdown voice only during Prepare
- Short tone at Work/Rest transitions

---

## ♿ Accessibility & Safety

### Current Issues
- Some tappables < 44×44pt
- Dynamic Type support needs improvement
- VoiceOver labels need enhancement

### Target
- All tappables ≥ 44×44pt
- Dynamic Type: up to XL cleanly
- VoiceOver: "Step 7 of 12, 23 seconds remaining, Jumping Jacks"
- Color isn't the only state indicator (also use labels and icons)

---

## ✅ Quick 1-Day Wins

1. ✅ Remove inset "frame" effect (PopupContainer)
2. ✅ Make Start Workout the only hero CTA
3. ✅ Move Customize/Plan/History into compact toolbar
4. ✅ Add 10-12% dark overlay behind hero text
5. ✅ Convert countdown screen to segmented ring
6. ✅ Tighten card labels (no truncation)
7. ✅ Reduce card corner radius (24pt/16pt)

---

## 📊 Implementation Priority

### Phase 1: Quick Wins (High Impact, Low Effort)
1. Remove PopupContainer framing
2. Update visual tokens (8pt grid, corners, shadows)
3. Add dark overlay for contrast
4. Reduce corner radius
5. Tighten labels

### Phase 2: Hero Card Redesign (High Impact, Medium Effort)
1. Create simplified hero card
2. Move secondary actions to compact toolbar
3. Simplify layout

### Phase 3: Player Redesign (High Impact, High Effort)
1. Create segmented ring (12 segments)
2. Add sticky control bar
3. Implement phase colors
4. Add haptics and voice cues

### Phase 4: Polish (Medium Impact, Medium Effort)
1. Improve microcopy
2. Enhance accessibility
3. Add motion transitions
4. Test Dynamic Type

---

## 🎯 Success Metrics

- [ ] Home screen: Single hero card, instant CTA
- [ ] Player: Segmented ring, clear controls
- [ ] Visual tokens: Consistent 8pt grid, 24/16pt corners
- [ ] Accessibility: All tappables ≥ 44pt, Dynamic Type XL
- [ ] Microcopy: Clear, action-oriented
- [ ] Motion: Smooth 180-220ms transitions

---

**Status:** Ready for implementation


