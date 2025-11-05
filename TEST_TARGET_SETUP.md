# Test Target Setup Guide

## Problem
Test files were in `SevenMinuteWorkout/Tests/` which caused them to be included in the main app target, resulting in errors:
- "Unable to find module dependency: 'XCTest'"
- "File 'X.swift' is part of module 'SevenMinuteWorkout'; ignoring import"

## Solution
Test files have been moved to a separate `SevenMinuteWorkoutTests/` folder at the root level (similar to `SevenMinuteWorkoutUITests/`).

## Next Steps in Xcode

### Step 1: Remove Test Files from Main App Target
1. Open `SevenMinuteWorkout.xcodeproj` in Xcode
2. Select the `SevenMinuteWorkout` target (main app)
3. Go to "Build Phases" → "Compile Sources"
4. Find and remove any test files:
   - `IntegrationTests.swift`
   - `WorkoutEngineTests.swift`
   - `WorkoutStoreTests.swift`
   - `PerformanceTests.swift`
   - Any files from `Mocks/` folder
5. If they appear in "Copy Bundle Resources", remove them there too

### Step 2: Add Test Files to Test Target
1. Select the `SevenMinuteWorkoutTests` target
2. Go to "Build Phases" → "Compile Sources"
3. Click the "+" button
4. Navigate to `SevenMinuteWorkoutTests/` folder
5. Add all test files:
   - `IntegrationTests.swift`
   - `WorkoutEngineTests.swift`
   - `WorkoutStoreTests.swift`
   - `PerformanceTests.swift`
   - All files from `Mocks/` folder

### Step 3: Delete Old Test Folder (Optional)
Once everything is working:
1. Delete `SevenMinuteWorkout/Tests/` folder (it's now empty)
2. Right-click → Delete → Move to Trash

### Step 4: Verify
1. Select the `SevenMinuteWorkoutTests` scheme
2. Press `Cmd+U` to run tests
3. Tests should compile and run without errors

## File Structure

```
SevenMinuteWorkout/
  ├── Tests/          ❌ DELETE THIS (old location)
  └── ...             (main app files)

SevenMinuteWorkoutTests/  ✅ NEW LOCATION
  ├── IntegrationTests.swift
  ├── WorkoutEngineTests.swift
  ├── WorkoutStoreTests.swift
  ├── PerformanceTests.swift
  └── Mocks/
      ├── MockHapticFeedback.swift
      ├── MockSoundFeedback.swift
      └── MockWorkoutTimer.swift
```

## Alternative: Quick Fix in Xcode

If you prefer to do it all in Xcode:

1. **Remove from main target:**
   - In Project Navigator, select all files in `SevenMinuteWorkout/Tests/`
   - In File Inspector (right panel), uncheck "Target Membership" for `SevenMinuteWorkout`
   
2. **Add to test target:**
   - Select the same files
   - In File Inspector, check "Target Membership" for `SevenMinuteWorkoutTests`

3. **Move files (optional):**
   - Drag the `Tests` folder from `SevenMinuteWorkout/` to `SevenMinuteWorkoutTests/` in Project Navigator

## Verification Checklist

- [ ] Test files removed from main app target
- [ ] Test files added to `SevenMinuteWorkoutTests` target
- [ ] Old `SevenMinuteWorkout/Tests/` folder deleted
- [ ] Tests compile without errors
- [ ] Tests run successfully (`Cmd+U`)

