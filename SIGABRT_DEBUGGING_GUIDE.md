# 🐛 SIGABRT Debugging Guide

**Date:** 2024-12-19  
**Status:** Comprehensive Analysis  
**Issue:** `__abort_with_payload` crash debugging checklist

---

## 🔍 Common SIGABRT Causes

### 1. ✅ UI Updates Off Main Thread
**Status:** CHECKED - Most operations are safe

**Potential Issues:**
- `WorkoutStore` modifies `@Published` properties - Need to verify MainActor isolation
- `HealthInsightsManager` updates `@Published` from async functions

**Fix Strategy:**
- Ensure all `@Published` property mutations happen on `@MainActor`
- Use `Task { @MainActor in ... }` for background operations that update UI

---

### 2. ✅ Array/Collection Access Issues
**Status:** FIXED - All bounds checking added

**Fixed Issues:**
- ✅ `WorkoutStore.deleteSession()` - Added bounds checking
- ✅ `WorkoutHistoryView.onDelete()` - Added bounds checking
- ✅ `HabitLearner` - Added bounds checking
- ✅ `LoadingStates` - Added bounds checking

---

### 3. ✅ Table/Collection View Inconsistencies
**Status:** CHECKED - Using SwiftUI Lists (safer)

**Analysis:**
- Using SwiftUI `List` and `ForEach` (not UIKit)
- SwiftUI handles diffing automatically
- No manual insert/delete operations that could cause inconsistencies

---

### 4. ✅ Mutating Collections While Iterating
**Status:** CHECKED - No unsafe mutations found

**Analysis:**
- All array modifications use safe patterns
- No mutations during iteration without proper guards

---

### 5. ✅ Data Races with @Published Properties
**Status:** NEEDS VERIFICATION

**Potential Issues:**

#### WorkoutStore.addSession()
```swift
// Line 68: Modifies @Published property
sessions.insert(newSession, at: 0)
totalWorkouts += 1
totalMinutes += session.duration / 60.0
```

**Check:** Is `addSession()` called from `@MainActor`?

#### WorkoutStore.load()
```swift
// Line 288: Modifies @Published property
sessions = validSessions
recalculateStatistics()
```

**Check:** Is `load()` called from `@MainActor`?

#### WorkoutStore.syncToHealthKit()
```swift
// Line 126: Task without @MainActor
Task {
    // Does not update @Published directly
}
```

**Status:** ✅ Safe - Only reads data, doesn't modify @Published

---

## 🛠️ Recommended Fixes

### Fix 1: Ensure @MainActor Isolation for WorkoutStore
**Location:** `Ritual7/Models/WorkoutStore.swift`

**Issue:** `@Published` properties should only be modified on main thread

**Fix:**
```swift
@MainActor
class WorkoutStore: ObservableObject {
    // All @Published properties
    @Published private(set) var sessions: [WorkoutSession] = []
    // ...
    
    func addSession(...) {
        // Already on MainActor, safe
        sessions.insert(newSession, at: 0)
        // ...
    }
    
    private func load() {
        // Ensure this runs on MainActor
        // ...
        sessions = validSessions
    }
}
```

**Or wrap mutations:**
```swift
func addSession(...) {
    Task { @MainActor in
        sessions.insert(newSession, at: 0)
        // ...
    }
}
```

---

### Fix 2: Ensure HealthInsightsManager Updates on MainActor
**Location:** `Ritual7/Health/HealthInsightsManager.swift`

**Issue:** `@Published` properties updated from async functions

**Fix:**
```swift
@MainActor
class HealthInsightsManager: ObservableObject {
    @Published var latestInsights: HealthInsight?
    // ...
    
    func analyzeWorkoutImpact() async throws -> HealthInsight {
        // ... async work ...
        
        // Update on MainActor
        await MainActor.run {
            self.latestInsights = insight
        }
    }
}
```

---

## 🔍 Debugging Steps

### Step 1: Add Exception Breakpoint
In Xcode → Breakpoint navigator:
- Add **Exception Breakpoint** (All, Break on throw)
- Add **Symbolic breakpoints** on:
  - `__abort_with_payload`
  - `__pthread_kill`
  - `fatalError`
  - `preconditionFailure`

### Step 2: Enable Runtime Checks
Edit Scheme → Diagnostics:
- ✅ **Main Thread Checker** (catches UI off main thread)
- ✅ **Thread Sanitizer** (catches data races)
- ✅ **Address Sanitizer** (catches memory issues)
- ✅ **Malloc Guard Edges** (catches buffer overflows)

### Step 3: Check Crash Log
Console.app → Crash Reports:
- Look for **"Application Specific Information"**
- Check **"Termination Reason"**
- Look for specific error messages

### Step 4: Symbolicate Addresses
In LLDB:
```lldb
image list -o -f
```

Then in Terminal:
```bash
atos -o <YourBinary> -arch arm64 -l <slide> 0x1053dac04 0x1053dac14
```

---

## 📋 Checklist

### Threading Issues
- [ ] Check if `WorkoutStore.addSession()` is called from `@MainActor`
- [ ] Check if `WorkoutStore.load()` is called from `@MainActor`
- [ ] Check if `HealthInsightsManager` updates happen on `@MainActor`
- [ ] Enable Main Thread Checker in Xcode

### Array Access Issues
- [x] ✅ All array access has bounds checking
- [x] ✅ All `remove()` operations validate indices
- [x] ✅ All `insert()` operations validate indices

### Collection View Issues
- [x] ✅ Using SwiftUI Lists (automatic diffing)
- [x] ✅ No manual insert/delete animations
- [x] ✅ No data source inconsistencies

### Force Unwraps
- [x] ✅ All force unwraps removed or safely guarded
- [x] ✅ All optional unwrapping is safe

---

## 🎯 Next Steps

1. **Enable Main Thread Checker** - This will catch UI updates off main thread
2. **Enable Thread Sanitizer** - This will catch data races
3. **Run the app** - Reproduce the crash
4. **Check the crash log** - Look for "Application Specific Information"
5. **Share the crash details** - If you can share the crash log, I can pinpoint the exact line

---

## ✅ Current Status

**Fixed Issues:**
- ✅ Array bounds checking
- ✅ Division by zero protection
- ✅ Force unwrap removal
- ✅ Task in deinit fixed

**Needs Verification:**
- ⚠️ `@MainActor` isolation for `WorkoutStore`
- ⚠️ `@MainActor` isolation for `HealthInsightsManager`
- ⚠️ Enable runtime checks to catch remaining issues

---

**Note:** The most likely remaining issue is `@Published` properties being modified from background threads. Enable Main Thread Checker to catch this automatically.

