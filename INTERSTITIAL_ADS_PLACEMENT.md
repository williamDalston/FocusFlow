# 📱 Interstitial Ads Placement Strategy - Pomodoro Timer

## 🎯 Overview

This document outlines the optimal placement strategy for interstitial ads in the Pomodoro Timer: Focus & Study app, balancing user experience with monetization.

## ✅ Best Practices

### ✅ DO:
- Show ads at natural break points (after completing focus sessions or breaks)
- Respect cooldown periods (90 seconds minimum between ads)
- Limit ads per session (max 3-4 per app launch)
- Show ads after user has engaged with the app
- Always allow users to dismiss ads
- Never interrupt active focus sessions

### ❌ DON'T:
- Show ads during active focus sessions
- Show ads immediately on app launch
- Show ads during onboarding
- Interrupt critical user flows
- Show ads more than 3-4 times per session
- Show ads during breaks (user needs rest)

## 📍 Recommended Placement Locations

### 🥇 Priority 1: After Focus Session Completion ⭐ BEST
**Location:** `SessionCompleteView` or focus completion handler
**Timing:** After user completes a 25-minute focus session
**Rationale:** 
- Natural break point after achievement
- User has completed their focus goal
- High engagement moment
- Non-intrusive timing
- Perfect for ad placement

**Implementation:**
```swift
// In SessionCompleteView or Focus completion handler
onDismiss: {
    // Show interstitial ad after focus session completion
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        InterstitialAdManager.shared.present(from: nil)
    }
    showCompletionView = false
    dismiss()
}
```

**Expected Frequency:** 1-2 ads per day (after focus sessions)

---

### 🥈 Priority 2: After Break Completion
**Location:** Break completion handler
**Timing:** After user completes a 5-minute or 15-minute break
**Rationale:**
- User is transitioning from break to next focus session
- Natural transition point
- User is ready to engage again
- Low urgency action

**Implementation:**
```swift
// In break completion handler
func breakCompleted() {
    // Show ad after break completion, before next focus session
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
        InterstitialAdManager.shared.present(from: nil)
    }
    startNextFocusSession()
}
```

**Expected Frequency:** 1-2 ads per day (after breaks)

---

### 🥉 Priority 3: After Viewing Statistics
**Location:** Statistics/Progress views dismissal
**Timing:** After user views statistics or progress charts and dismisses
**Rationale:**
- User is browsing, not actively focusing
- Natural transition point
- Low urgency action
- User is engaged with app content

**Implementation:**
```swift
// In StatisticsView or ProgressView
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
            // Show ad after viewing statistics
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
                InterstitialAdManager.shared.present(from: nil)
            }
            dismiss()
        }
    }
}
```

**Expected Frequency:** 1 ad per session (after viewing stats)

---

### 🏃 Priority 4: After Viewing History Details
**Location:** Focus session history detail view dismissal
**Timing:** After user views focus session details and dismisses
**Rationale:**
- User is browsing past sessions
- Natural transition point
- Low urgency action
- User is engaged with app content

**Implementation:**
```swift
// In FocusSessionDetailView
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
            // Show ad after viewing session details
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
                InterstitialAdManager.shared.present(from: nil)
            }
            dismiss()
        }
    }
}
```

**Expected Frequency:** 1 ad per session (after viewing history)

---

### 🚫 Priority 5: App Launch (Not Recommended)
**Location:** `PomodoroTimerApp.onAppear`
**Timing:** After first successful focus session (not on first launch)
**Rationale:**
- Only if user has completed at least one focus session
- Never on first launch
- Avoid interrupting onboarding

**Implementation:**
```swift
// Only show after user has completed focus sessions
if focusStore.totalSessions > 0 {
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        InterstitialAdManager.shared.present(from: nil)
    }
}
```

**Expected Frequency:** Rare (only after first session completion)

---

## 🔧 Configuration

### Current Settings (in `InterstitialAdManager.swift`):
```swift
var sessionCap = 3                 // Max 3 ads per app launch
var minimumSecondsBetween = 90.0   // 90 second cooldown between ads
```

### Recommended Tuning for Pomodoro App:
- **sessionCap**: 3-4 (good balance - more sessions per day than workouts)
- **minimumSecondsBetween**: 90-120 seconds (prevents ad fatigue)
- **Load ads proactively**: Pre-load next ad after showing one

### Optimal Ad Frequency:
- **After Focus Sessions**: 1-2 ads per day (primary revenue)
- **After Breaks**: 1-2 ads per day (secondary revenue)
- **After Viewing Stats**: 1 ad per session (additional revenue)
- **Total**: 3-4 ads per day maximum

---

## 📊 Expected User Experience

### Flow Example:
1. User completes 25-minute focus session → Completion screen appears
2. User dismisses completion → Interstitial ad shows (after 0.5 seconds)
3. User closes ad → Returns to main screen
4. User completes break → Ad shows (if cooldown passed)
5. User views statistics → Dismisses → Ad shows (if cooldown passed)
6. User continues → No more ads (cap reached or cooldown active)

### Daily User Flow:
1. **Morning Focus Session** → Ad after completion
2. **Break** → Ad after break (if cooldown passed)
3. **Afternoon Focus Session** → Ad after completion
4. **Viewing Statistics** → Ad after dismissing stats
5. **Total**: 3-4 ads per day maximum

---

## 🎨 Implementation Notes

### Ad Manager Setup:
The `InterstitialAdManager` already handles:
- ✅ Automatic eligibility checking
- ✅ Session cap enforcement
- ✅ Cooldown enforcement
- ✅ Auto-reload after dismissal
- ✅ Error handling

### Integration Points:
1. **SessionCompleteView**: Add to `onDismiss` callback
2. **Break completion handler**: Add to break completion
3. **StatisticsView**: Add to "Done" button
4. **FocusSessionDetailView**: Add to "Done" button
5. **RootView**: Optional tab switch tracking (use sparingly)

### Critical Rules:
1. **Never show ads during active focus sessions**
2. **Never show ads during breaks** (user needs rest)
3. **Always use delays** (0.3-0.5 seconds) for smooth UX
4. **Respect cooldowns** (90 seconds minimum)
5. **Enforce session caps** (3-4 ads maximum)

---

## 🚀 Implementation Checklist

- [x] Ad manager is already implemented
- [ ] Integrate into focus session completion
- [ ] Integrate into break completion
- [ ] Integrate into statistics view dismissal
- [ ] Integrate into history detail view dismissal
- [ ] Test ad frequency and timing
- [ ] Test on physical devices
- [ ] Monitor user feedback and adjust

---

## 📈 Monitoring

Track these metrics:
- Ad show frequency per session
- Ad placement effectiveness (completion vs. break vs. stats)
- User engagement after ads
- App retention impact
- Revenue per session
- User complaints about ad frequency

Adjust placement and frequency based on data!

---

## 🎯 Success Criteria

### User Experience:
- ✅ Ads don't interrupt focus sessions
- ✅ Ads don't interrupt breaks
- ✅ Ads appear at natural break points
- ✅ Users don't complain about ad frequency
- ✅ App retention remains high

### Monetization:
- ✅ 3-4 ads shown per day (on average)
- ✅ High ad fill rate (>90%)
- ✅ Good revenue per session
- ✅ Optimal placement timing

---

## 📝 Notes

### Why This Strategy Works:
1. **Natural Break Points**: Focus sessions and breaks are natural break points
2. **User Engagement**: Users are highly engaged after completing sessions
3. **Non-Intrusive**: Ads never interrupt active focus or rest time
4. **Optimal Frequency**: 3-4 ads per day is reasonable for free app
5. **Revenue Maximization**: Ads at completion moments have highest engagement

### Future Optimizations:
- A/B test ad frequency (3 vs. 4 ads per day)
- A/B test ad timing delays (0.3s vs. 0.5s)
- A/B test ad placement (completion vs. break vs. stats)
- Monitor user feedback and adjust accordingly
