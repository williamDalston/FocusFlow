# 📱 Interstitial Ads Placement Strategy

## 🎯 Overview

This document outlines the optimal placement strategy for interstitial ads in the 7-Minute Workout app, balancing user experience with monetization.

## ✅ Best Practices

### ✅ DO:
- Show ads at natural break points (after completing actions)
- Respect cooldown periods (90 seconds minimum between ads)
- Limit ads per session (max 3 per app launch)
- Show ads after user has engaged with the app
- Always allow users to dismiss ads

### ❌ DON'T:
- Show ads during active workouts
- Show ads immediately on app launch
- Show ads during onboarding
- Interrupt critical user flows
- Show ads more than 3 times per session

## 📍 Recommended Placement Locations

### 🥇 Priority 1: After Workout Completion ⭐ BEST
**Location:** `CompletionCelebrationView.onDismiss`
**Timing:** After user dismisses completion screen
**Rationale:** 
- Natural break point after achievement
- User has completed their goal
- High engagement moment
- Non-intrusive timing

**Implementation:**
```swift
// In CompletionCelebrationView
onDismiss: {
    // Show interstitial ad after celebration
    InterstitialAdManager.shared.present(from: nil)
    showCompletionCelebration = false
    dismiss()
}
```

---

### 🥈 Priority 2: After Viewing Workout History Details
**Location:** `WorkoutSessionDetailView.onDismiss`
**Timing:** After user views workout details and dismisses
**Rationale:**
- User is browsing, not actively working out
- Natural transition point
- Low urgency action

**Implementation:**
```swift
// In WorkoutSessionDetailView
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
            // Show ad after viewing details
            InterstitialAdManager.shared.present(from: nil)
            dismiss()
        }
    }
}
```

---

### 🥉 Priority 3: After Viewing Exercise Guide
**Location:** `ExerciseGuideView.onDismiss`
**Timing:** After user views exercise instructions
**Rationale:**
- Educational content viewing
- Natural break point
- User is learning, not actively exercising

**Implementation:**
```swift
// In ExerciseGuideView
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
            // Show ad after viewing guide
            InterstitialAdManager.shared.present(from: nil)
            dismiss()
        }
    }
}
```

---

### 🏃 Priority 4: Tab Switches (Optional - Use Sparingly)
**Location:** `RootView` tab switching
**Timing:** After 3-4 tab switches within 30 seconds
**Rationale:**
- Indicates user is browsing
- Not interrupting critical actions
- Use sparingly to avoid annoyance

**Implementation:**
```swift
// Track tab switches
@State private var tabSwitchCount = 0
@State private var lastTabSwitchTime: Date?

.onChange(of: selectedTab) { _ in
    tabSwitchCount += 1
    lastTabSwitchTime = Date()
    
    // Show ad after 3 switches in 30 seconds
    if tabSwitchCount >= 3,
       let lastSwitch = lastTabSwitchTime,
       Date().timeIntervalSince(lastSwitch) < 30 {
        InterstitialAdManager.shared.present(from: nil)
        tabSwitchCount = 0
    }
}
```

---

### 🚫 Priority 5: App Launch (Low Priority - Not Recommended)
**Location:** `SevenMinuteWorkoutApp.onAppear`
**Timing:** After first successful workout (not on first launch)
**Rationale:**
- Only if user has completed at least one workout
- Never on first launch
- Avoid interrupting onboarding

**Implementation:**
```swift
// Only show after user has completed workouts
if workoutStore.totalWorkouts > 0 {
    // Small delay to let app fully load
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        InterstitialAdManager.shared.present(from: nil)
    }
}
```

## 🔧 Configuration

### Current Settings (in `InterstitialAdManager.swift`):
```swift
var sessionCap = 3                 // Max 3 ads per app launch
var minimumSecondsBetween = 90.0   // 90 second cooldown between ads
```

### Recommended Tuning:
- **sessionCap**: Keep at 3 (good balance)
- **minimumSecondsBetween**: 90-120 seconds (prevents ad fatigue)
- **Load ads proactively**: Pre-load next ad after showing one

## 📊 Expected User Experience

### Flow Example:
1. User completes workout → Celebration screen appears
2. User dismisses celebration → Interstitial ad shows (after 1-2 seconds)
3. User closes ad → Returns to main screen
4. User browses history → Views details → Dismisses → Ad shows (if cooldown passed)
5. User continues browsing → No more ads (cap reached or cooldown active)

## 🎨 Implementation Notes

### Ad Manager Setup:
The `InterstitialAdManager` already handles:
- ✅ Automatic eligibility checking
- ✅ Session cap enforcement
- ✅ Cooldown enforcement
- ✅ Auto-reload after dismissal
- ✅ Error handling

### Integration Points:
1. **CompletionCelebrationView**: Add to `onDismiss` callback
2. **WorkoutSessionDetailView**: Add to "Done" button
3. **ExerciseGuideView**: Add to "Done" button
4. **RootView**: Optional tab switch tracking

## 🚀 Next Steps

1. ✅ Ad manager is already implemented
2. ⏳ Integrate into completion celebration
3. ⏳ Integrate into history detail view
4. ⏳ Integrate into exercise guide view
5. ⏳ Test ad frequency and timing
6. ⏳ Monitor user feedback and adjust

## 📈 Monitoring

Track these metrics:
- Ad show frequency per session
- User engagement after ads
- App retention impact
- Revenue per session

Adjust placement and frequency based on data!

