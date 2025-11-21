# Project Structure Analysis - FocusFlow vs Ritual7

## Summary

**Both projects are in the same directory** (`/Users/williamalston/Desktop/cool_app`), but they appear to be **the same app with different project files**.

---

## Current Directory: `/Users/williamalston/Desktop/cool_app`

### 1. FocusFlow.xcodeproj
- **Bundle ID:** `com.williamalston.focustimeralston`
- **App Name:** "Alston Focus Timer" (from Info.plist)
- **Source Folder:** `FocusFlow/`
- **Status:** ✅ Active project - This is your FocusFlow app
- **Target Name:** FocusFlow

### 2. Ritual7.xcodeproj
- **Bundle ID:** `williamalston.FocusFlow` ⚠️ (Note: This is confusing - it says "Ritual7" but has "FocusFlow" bundle ID)
- **Source Folder:** `FocusFlow/` (same as FocusFlow.xcodeproj!)
- **Status:** ⚠️ **This appears to be a duplicate/legacy project file**
- **Target Name:** FocusFlow (same as FocusFlow.xcodeproj)

### 3. SevenMinuteWorkout.xcodeproj
- **Status:** Legacy project (old workout app)
- **Source Folder:** `SevenMinuteWorkout/`

---

## Key Findings

### ❌ **Ritual7.xcodeproj is NOT a separate Ritual7 app**

Both `FocusFlow.xcodeproj` and `Ritual7.xcodeproj` point to the **same source code** in the `FocusFlow/` folder. They are building the same app, just with different project file names.

**Evidence:**
- Both projects reference `path = FocusFlow;` in their project.pbxproj files
- Both build `FocusFlow.app`
- Ritual7.xcodeproj has bundle ID `williamalston.FocusFlow` (not a Ritual7 bundle ID)
- The `Ritual7/` folder only contains legacy Views/Progress files, not a full app

### ✅ **FocusFlow.xcodeproj is your active FocusFlow app**

This is the project you should be using for your FocusFlow app in App Store Connect.

---

## Directory Structure

```
/Users/williamalston/Desktop/cool_app/
├── FocusFlow.xcodeproj          ← FocusFlow app (bundle: com.williamalston.focustimeralston)
├── Ritual7.xcodeproj            ← DUPLICATE (points to same FocusFlow/ folder)
├── SevenMinuteWorkout.xcodeproj ← Legacy workout app
├── FocusFlow/                    ← Source code for FocusFlow app
│   ├── Info.plist               ← "Alston Focus Timer"
│   └── [all app source files]
├── Ritual7/                      ← Legacy files only (Views/Progress)
│   └── Views/Progress/           ← Old chart views (not used)
└── SevenMinuteWorkout/           ← Legacy workout app code
```

---

## Duplicate Directory Found

There's also a **duplicate directory** at:
- `/Users/williamalston/Desktop/cool_app copy/`

This appears to be a backup copy with the same projects.

---

## Recommendations

### For FocusFlow App (App Store Connect)
✅ **Use:** `FocusFlow.xcodeproj`
- Bundle ID: `com.williamalston.focustimeralston`
- App Name: "Alston Focus Timer"

### For Ritual7 App (App Store Connect)
❓ **Question:** Do you have a separate Ritual7 app, or was Ritual7 renamed to FocusFlow?

**If Ritual7 is a separate app:**
- You may need to find the original Ritual7 project elsewhere
- Or create a new project for Ritual7 with a different bundle ID

**If Ritual7 was renamed to FocusFlow:**
- You can safely ignore `Ritual7.xcodeproj` (it's a duplicate)
- Delete it to avoid confusion

---

## Next Steps

1. **Check App Store Connect:**
   - What bundle IDs do you have registered?
   - Is "Ritual7" a separate app or was it renamed?

2. **If Ritual7 is separate:**
   - Search for the original Ritual7 project elsewhere on your computer
   - Or check if it's in a different location

3. **If Ritual7 was renamed:**
   - You can delete `Ritual7.xcodeproj` (it's redundant)
   - Keep only `FocusFlow.xcodeproj` for the FocusFlow app

---

## Bundle IDs Found

| Project File | Bundle ID | App Name | Status |
|-------------|-----------|----------|--------|
| FocusFlow.xcodeproj | `com.williamalston.focustimeralston` | Alston Focus Timer | ✅ Active |
| Ritual7.xcodeproj | `williamalston.FocusFlow` | (same as FocusFlow) | ⚠️ Duplicate |

---

**Conclusion:** You have **one app** (FocusFlow) with **two project files** pointing to the same source code. The `Ritual7.xcodeproj` appears to be a legacy/duplicate project file that should be removed or renamed.

