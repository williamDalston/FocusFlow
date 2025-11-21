# iOS Apps Location Summary

## ✅ Found Two Separate iOS Apps

After searching your Desktop, I found **two separate iOS apps**:

---

## 1. FocusFlow (Pomodoro Timer App)

**Location:** `/Users/williamalston/Desktop/cool_app/`

### Project Files:
- **Main Project:** `FocusFlow.xcodeproj`
- **Bundle ID:** `com.williamalston.focustimeralston`
- **App Name:** "Alston Focus Timer"
- **Source Folder:** `FocusFlow/`

### Status:
- ✅ Active project
- ✅ This is your FocusFlow app for App Store Connect
- ✅ Pomodoro timer app (focus sessions)

### Additional Files:
- `Ritual7.xcodeproj` - ⚠️ **DUPLICATE** (points to same FocusFlow/ folder, bundle ID: `williamalston.FocusFlow`)
- `SevenMinuteWorkout.xcodeproj` - Legacy workout app project

---

## 2. Ritual7 (Original Workout App)

**Location:** `/Users/williamalston/Desktop/01-Projects/apps/07-Fitness/7 Minute Workout/`

### Project Files:
- **Main Project:** `Ritual7.xcodeproj`
- **Source Folder:** `Ritual7/`
- **Watch App:** `Ritual7Watch/`
- **Tests:** `Ritual7Tests/`, `Ritual7UITests/`

### Status:
- ✅ Separate project
- ✅ Original Ritual7 workout app
- ✅ This appears to be the 7-Minute Workout app

### Notes:
- This is the original Ritual7 app location
- It's in a different directory structure (`01-Projects/apps/07-Fitness/`)
- This is likely your separate Ritual7 app for App Store Connect

---

## Summary

| App Name | Location | Bundle ID | Project File | Status |
|----------|----------|-----------|--------------|--------|
| **FocusFlow** | `/Users/williamalston/Desktop/cool_app/` | `com.williamalston.focustimeralston` | `FocusFlow.xcodeproj` | ✅ Active |
| **Ritual7** | `/Users/williamalston/Desktop/01-Projects/apps/07-Fitness/7 Minute Workout/` | (Need to check) | `Ritual7.xcodeproj` | ✅ Separate App |

---

## Key Findings

### In `cool_app/` directory:
1. **FocusFlow.xcodeproj** - Your active FocusFlow app
   - Bundle ID: `com.williamalston.focustimeralston`
   - App Name: "Alston Focus Timer"
   - Source: `FocusFlow/` folder

2. **Ritual7.xcodeproj** - ⚠️ **DUPLICATE/LEGACY**
   - Bundle ID: `williamalston.FocusFlow` (confusing - says Ritual7 but has FocusFlow bundle ID)
   - Points to same `FocusFlow/` folder
   - This is NOT a separate app - it's a duplicate project file

3. **SevenMinuteWorkout.xcodeproj** - Legacy workout app

### In `01-Projects/apps/07-Fitness/7 Minute Workout/`:
1. **Ritual7.xcodeproj** - ✅ **ORIGINAL RITUAL7 APP**
   - This is your separate Ritual7 app
   - Original location for the workout app
   - Separate from FocusFlow

---

## Recommendations

### For FocusFlow App:
✅ **Use:** `/Users/williamalston/Desktop/cool_app/FocusFlow.xcodeproj`
- This is your active FocusFlow app
- Bundle ID: `com.williamalston.focustimeralston`

### For Ritual7 App:
✅ **Use:** `/Users/williamalston/Desktop/01-Projects/apps/07-Fitness/7 Minute Workout/Ritual7.xcodeproj`
- This is your separate Ritual7 app
- Original workout app location

### Cleanup:
- You can safely delete `/Users/williamalston/Desktop/cool_app/Ritual7.xcodeproj` (it's a duplicate)
- The `Ritual7/` folder in `cool_app/` only contains legacy Views/Progress files (can be removed)

---

## Next Steps

1. **Verify Bundle IDs in App Store Connect:**
   - Check what bundle IDs you have registered
   - Match them to the correct project files

2. **Open the correct projects:**
   - FocusFlow: Open `cool_app/FocusFlow.xcodeproj`
   - Ritual7: Open `01-Projects/apps/07-Fitness/7 Minute Workout/Ritual7.xcodeproj`

3. **Clean up duplicates:**
   - Remove `cool_app/Ritual7.xcodeproj` (duplicate)
   - Remove `cool_app/Ritual7/` folder (legacy files only)

---

**Conclusion:** You have **two separate apps** in **two different locations**. FocusFlow is in `cool_app/`, and Ritual7 is in `01-Projects/apps/07-Fitness/7 Minute Workout/`.

