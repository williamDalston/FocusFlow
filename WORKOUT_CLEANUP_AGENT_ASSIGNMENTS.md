# Workout Code Cleanup - Agent Assignments

## 🎯 Goal
Remove all workout-related code and terminology from the FocusFlow codebase, ensuring the app is fully focused on Pomodoro timer functionality.

## 📋 Agent Overview

| Agent | Focus Area | Priority | Estimated Time |
|-------|-----------|----------|----------------|
| **Agent 21** | Critical RootView & Settings Fixes | CRITICAL | 2-3 hours |
| **Agent 22** | Delete Workout Views & Models | HIGH | 2-3 hours |
| **Agent 23** | Refactor WorkoutShareManager | HIGH | 2-3 hours |
| **Agent 24** | Refactor Widget & Shortcuts | MEDIUM | 1-2 hours |
| **Agent 25** | Update Export & Sharing Code | MEDIUM | 2-3 hours |
| **Agent 26** | Delete Workout Directory Files | HIGH | 1-2 hours |
| **Agent 27** | Update Test Files | MEDIUM | 2-3 hours |
| **Agent 28** | Update Terminology in Code | MEDIUM | 3-4 hours |
| **Agent 29** | Update User-Facing Strings | LOW | 2-3 hours |
| **Agent 30** | Final Project Cleanup & Verification | HIGH | 1-2 hours |

**Total Estimated Time**: 18-27 hours

---

## 🚨 Agent 21: Critical RootView & Settings Fixes

**Priority**: CRITICAL (Blocking)  
**Estimated Time**: 2-3 hours  
**Dependencies**: None (must be done first)

### Tasks

1. **Fix RootView.swift**
   - [ ] Remove `@EnvironmentObject private var workoutStore: WorkoutStore` (line 620)
   - [ ] Verify `FocusStore` is already being used (line 10)
   - [ ] Ensure only `FocusContentView()` is used (not `WorkoutContentView()`)
   - [ ] Ensure only `FocusHistoryView()` is used (not `WorkoutHistoryView()`)
   - [ ] Remove any workout-related environment objects
   - [ ] Test that app still builds and runs

2. **Fix SettingsView.swift**
   - [ ] Remove `@EnvironmentObject private var workoutStore: WorkoutStore` (line 10)
   - [ ] Replace with `@EnvironmentObject private var focusStore: FocusStore`
   - [ ] Update all `workoutStore` references to `focusStore`
   - [ ] Update workout terminology to focus terminology
   - [ ] Update workout preferences to focus preferences
   - [ ] Test that settings still work

3. **Fix Export.swift**
   - [ ] Remove `@EnvironmentObject private var workoutStore: WorkoutStore`
   - [ ] Replace with `@EnvironmentObject private var focusStore: FocusStore`
   - [ ] Update export functions to use `FocusSession` instead of `WorkoutSession`
   - [ ] Update export methods to export focus sessions
   - [ ] Test export functionality

### Files to Modify
- `FocusFlow/RootView.swift`
- `FocusFlow/SettingsView.swift`
- `FocusFlow/Sharing/Export.swift`

### Success Criteria
- [ ] No compilation errors
- [ ] App builds successfully
- [ ] No `WorkoutStore` references in RootView, SettingsView, or Export
- [ ] App runs without crashes
- [ ] Settings page works correctly

---

## 🔥 Agent 22: Delete Workout Views & Models

**Priority**: HIGH  
**Estimated Time**: 2-3 hours  
**Dependencies**: Agent 21 (must fix references first)

### Tasks

1. **Delete Workout History Views**
   - [ ] Delete `FocusFlow/Views/History/WorkoutHistoryView.swift`
   - [ ] Delete `FocusFlow/Views/History/WorkoutHistoryRow.swift`
   - [ ] Delete `FocusFlow/Views/History/WorkoutHistoryFilterView.swift`
   - [ ] Verify `FocusHistoryView`, `FocusHistoryRow`, `FocusHistoryFilterView` exist and work
   - [ ] Remove from project.pbxproj

2. **Delete Exercise Views**
   - [ ] Delete `FocusFlow/Views/Exercises/ExerciseListView.swift`
   - [ ] Delete `FocusFlow/Views/Customization/ExerciseSelectorView.swift`
   - [ ] Delete `FocusFlow/Views/Exercises/` directory if empty
   - [ ] Remove from project.pbxproj

3. **Delete Workout Customization Views**
   - [ ] Delete `FocusFlow/Views/Customization/WorkoutCustomizationView.swift` (or refactor if needed)
   - [ ] Delete `FocusFlow/Views/Customization/WorkoutTemplateManager.swift` (or refactor if needed)
   - [ ] Verify `FocusCustomizationView` exists and works
   - [ ] Remove from project.pbxproj

4. **Delete Workout Onboarding**
   - [ ] Delete `FocusFlow/Onboarding/FirstWorkoutTutorialView.swift`
   - [ ] Delete `FocusFlow/Onboarding/FitnessLevelAssessmentView.swift` (if not needed)
   - [ ] Verify `FirstFocusTutorialView` exists and works
   - [ ] Remove from project.pbxproj

5. **Delete Workout Models** (if they exist)
   - [ ] Delete `FocusFlow/Models/WorkoutSession.swift`
   - [ ] Delete `FocusFlow/Models/WorkoutStore.swift`
   - [ ] Delete `FocusFlow/Models/Exercise.swift`
   - [ ] Delete `FocusFlow/Models/CustomWorkout.swift`
   - [ ] Delete `FocusFlow/Models/WorkoutPreset.swift`
   - [ ] Delete `FocusFlow/Models/WorkoutPreferencesStore.swift`
   - [ ] Remove from project.pbxproj

### Files to Delete
- `FocusFlow/Views/History/WorkoutHistoryView.swift`
- `FocusFlow/Views/History/WorkoutHistoryRow.swift`
- `FocusFlow/Views/History/WorkoutHistoryFilterView.swift`
- `FocusFlow/Views/Exercises/ExerciseListView.swift`
- `FocusFlow/Views/Customization/ExerciseSelectorView.swift`
- `FocusFlow/Views/Customization/WorkoutCustomizationView.swift` (if not refactored)
- `FocusFlow/Views/Customization/WorkoutTemplateManager.swift` (if not refactored)
- `FocusFlow/Onboarding/FirstWorkoutTutorialView.swift`
- `FocusFlow/Onboarding/FitnessLevelAssessmentView.swift` (if not needed)
- Plus any workout models found

### Success Criteria
- [ ] All workout views deleted
- [ ] All workout models deleted (if they exist)
- [ ] Project builds successfully
- [ ] No broken references
- [ ] Focus equivalents work correctly

---

## 📤 Agent 23: Refactor WorkoutShareManager

**Priority**: HIGH  
**Estimated Time**: 2-3 hours  
**Dependencies**: Agent 21 (must fix RootView first)

### Tasks

1. **Rename WorkoutShareManager.swift**
   - [ ] Rename `FocusFlow/Sharing/WorkoutShareManager.swift` → `FocusFlow/Sharing/FocusShareManager.swift`
   - [ ] Update class name: `WorkoutShareManager` → `FocusShareManager`
   - [ ] Update all internal references
   - [ ] Update project.pbxproj

2. **Refactor Sharing Methods**
   - [ ] Rename `shareWorkoutCompletion()` → `shareFocusSession()`
   - [ ] Update method signatures to use `FocusSession` instead of `WorkoutSession`
   - [ ] Update `shareTextForWorkoutCompletion()` → `shareTextForFocusSession()`
   - [ ] Update sharing text from "workout" → "focus session"
   - [ ] Update sharing text from "exercises completed" → appropriate focus metrics

3. **Update ShareImageGenerator**
   - [ ] Update `generateWorkoutCompletionImage()` → `generateFocusCompletionImage()`
   - [ ] Update method to use `FocusSession` instead of `WorkoutSession`
   - [ ] Update image text from "workout" → "focus session"
   - [ ] Update metrics (remove exercises, use focus duration)

4. **Update PosterExporter**
   - [ ] Update `generateWorkoutCompletionPoster()` → `generateFocusCompletionPoster()`
   - [ ] Update methods to use `FocusSession`
   - [ ] Update poster text and metrics
   - [ ] Update "Ritual7" references to "FocusFlow" (if any)

5. **Update All Imports**
   - [ ] Find all files importing `WorkoutShareManager`
   - [ ] Update to import `FocusShareManager`
   - [ ] Update all usage references

### Files to Modify
- `FocusFlow/Sharing/WorkoutShareManager.swift` → `FocusShareManager.swift`
- `FocusFlow/Sharing/ShareImageGenerator.swift`
- `FocusFlow/Sharing/PosterExporter.swift`
- `FocusFlow/Sharing/PosterRenderer.swift` (if needed)
- Any files using WorkoutShareManager

### Files to Search & Update
- Search for: `WorkoutShareManager`
- Search for: `shareWorkoutCompletion`
- Search for: `generateWorkoutCompletionImage`

### Success Criteria
- [ ] File renamed successfully
- [ ] All methods refactored
- [ ] All imports updated
- [ ] Sharing functionality works
- [ ] No compilation errors

---

## 📱 Agent 24: Refactor Widget & Shortcuts

**Priority**: MEDIUM  
**Estimated Time**: 1-2 hours  
**Dependencies**: None

### Tasks

1. **Rename WorkoutWidget.swift**
   - [ ] Rename `FocusFlow/Widgets/WorkoutWidget.swift` → `FocusFlow/Widgets/FocusWidget.swift`
   - [ ] Update struct name: `WorkoutWidget` → `FocusWidget`
   - [ ] Update all widget references
   - [ ] Update widget display name from "Ritual7" → "FocusFlow"
   - [ ] Update widget description
   - [ ] Update widget content to show focus sessions, not workouts
   - [ ] Update project.pbxproj

2. **Handle WorkoutShortcuts.swift**
   - [ ] Check if `FocusFlow/Shortcuts/FocusShortcuts.swift` exists
   - [ ] If FocusShortcuts exists:
     - [ ] Delete `FocusFlow/Shortcuts/WorkoutShortcuts.swift`
     - [ ] Verify FocusShortcuts has all needed functionality
   - [ ] If FocusShortcuts doesn't exist:
     - [ ] Rename `WorkoutShortcuts.swift` → `FocusShortcuts.swift`
     - [ ] Refactor `WorkoutShortcuts` → `FocusShortcuts`
     - [ ] Update all shortcut types
     - [ ] Update shortcut titles from "workout" → "focus"
   - [ ] Update project.pbxproj

3. **Update Widget Configuration**
   - [ ] Update widget bundle identifier
   - [ ] Update widget display name in Info.plist
   - [ ] Test widget on device/simulator

### Files to Modify
- `FocusFlow/Widgets/WorkoutWidget.swift` → `FocusWidget.swift`
- `FocusFlow/Shortcuts/WorkoutShortcuts.swift` → Delete or refactor
- `FocusFlow/Shortcuts/FocusShortcuts.swift` (if exists, verify)

### Success Criteria
- [ ] Widget renamed and working
- [ ] Shortcuts updated or removed
- [ ] Widget displays focus data correctly
- [ ] No compilation errors
- [ ] Widget tested on device

---

## 💾 Agent 25: Update Export & Sharing Code

**Priority**: MEDIUM  
**Estimated Time**: 2-3 hours  
**Dependencies**: Agent 21, Agent 23

### Tasks

1. **Update Export.swift**
   - [ ] Already done in Agent 21, verify it's complete
   - [ ] Update export functions to export `FocusSession` data
   - [ ] Update CSV headers from workout metrics → focus metrics
   - [ ] Update JSON export to use FocusSession structure
   - [ ] Remove any workout-specific export fields

2. **Update ShareImageGenerator.swift**
   - [ ] Update all `workout` references → `focus`
   - [ ] Update image generation to use focus session data
   - [ ] Update text overlays from "workout" → "focus session"
   - [ ] Update metrics display (duration, completion status)
   - [ ] Remove exercise-specific metrics

3. **Update PosterExporter.swift**
   - [ ] Update all workout references → focus
   - [ ] Update poster generation for focus sessions
   - [ ] Update poster text and styling
   - [ ] Update metrics displayed on posters

4. **Update PosterRenderer.swift**
   - [ ] Check for any workout references
   - [ ] Update to use focus terminology
   - [ ] Update app name references

5. **Test All Sharing Functionality**
   - [ ] Test sharing focus session completion
   - [ ] Test sharing focus streaks
   - [ ] Test sharing achievements
   - [ ] Test image generation
   - [ ] Test poster generation

### Files to Modify
- `FocusFlow/Sharing/Export.swift`
- `FocusFlow/Sharing/ShareImageGenerator.swift`
- `FocusFlow/Sharing/PosterExporter.swift`
- `FocusFlow/Sharing/PosterRenderer.swift`

### Success Criteria
- [ ] All sharing code uses focus terminology
- [ ] All sharing methods work correctly
- [ ] Images and posters display correctly
- [ ] Export functions work
- [ ] No compilation errors

---

## 🗑️ Agent 26: Delete Workout Directory Files

**Priority**: HIGH  
**Estimated Time**: 1-2 hours  
**Dependencies**: Agent 21, Agent 22 (verify nothing uses these files)

### Tasks

1. **Delete Workout Engine Files**
   - [ ] Delete `FocusFlow/Workout/WorkoutEngine.swift`
   - [ ] Verify `PomodoroEngine.swift` exists and works
   - [ ] Remove from project.pbxproj

2. **Delete Workout Timer**
   - [ ] Delete `FocusFlow/Workout/WorkoutTimer.swift`
   - [ ] Verify `FocusTimer.swift` exists and works
   - [ ] Remove from project.pbxproj

3. **Delete Workout Utilities**
   - [ ] Delete `FocusFlow/Workout/FormFeedbackSystem.swift`
   - [ ] Delete `FocusFlow/Workout/RepCounter.swift`
   - [ ] Delete `FocusFlow/Workout/VoiceCuesManager.swift`
   - [ ] Remove from project.pbxproj

4. **Handle SegmentedProgressRing**
   - [ ] Check if `SegmentedProgressRing.swift` is used by focus code
   - [ ] If not used: Delete it
   - [ ] If used: Keep it (it's generic, not workout-specific)
   - [ ] Remove from project.pbxproj if deleted

5. **Delete Workout Directory**
   - [ ] Delete `FocusFlow/Workout/` directory if empty
   - [ ] Remove from project.pbxproj

6. **Verify No Broken References**
   - [ ] Search for imports of deleted files
   - [ ] Remove any broken imports
   - [ ] Build project to check for errors

### Files to Delete
- `FocusFlow/Workout/WorkoutEngine.swift`
- `FocusFlow/Workout/WorkoutTimer.swift`
- `FocusFlow/Workout/FormFeedbackSystem.swift`
- `FocusFlow/Workout/RepCounter.swift`
- `FocusFlow/Workout/VoiceCuesManager.swift`
- `FocusFlow/Workout/SegmentedProgressRing.swift` (if not used)
- `FocusFlow/Workout/` directory (if empty)

### Success Criteria
- [ ] All workout directory files deleted
- [ ] Project builds successfully
- [ ] No broken imports
- [ ] Focus equivalents work correctly
- [ ] Workout directory removed

---

## 🧪 Agent 27: Update Test Files

**Priority**: MEDIUM  
**Estimated Time**: 2-3 hours  
**Dependencies**: Agent 21, Agent 22, Agent 26

### Tasks

1. **Update Test Imports**
   - [ ] Update `@testable import Ritual7` → `@testable import FocusFlow` (already done ✅)
   - [ ] Update `@testable import Ritual7Watch` → `@testable import FocusFlowWatch` (already done ✅)
   - [ ] Verify all test files use correct imports

2. **Rename or Delete Workout Tests**
   - [ ] Check if `WorkoutEngineTests.swift` exists
     - If exists: Rename to `PomodoroEngineTests.swift` or DELETE if PomodoroEngine is tested elsewhere
   - [ ] Check if `WorkoutStoreTests.swift` exists
     - If exists: Rename to `FocusStoreTests.swift` or DELETE if FocusStore is tested elsewhere
   - [ ] Update test class names and methods
   - [ ] Update test assertions to use Focus models

3. **Update Mock Files**
   - [ ] Rename `MockWorkoutTimer.swift` → `MockFocusTimer.swift` or DELETE
   - [ ] Update `MockWorkoutTimer` class → `MockFocusTimer`
   - [ ] Update all test files using mocks
   - [ ] Update mock implementations to match FocusTimer protocol

4. **Update Test References**
   - [ ] Search for `WorkoutSession` in tests → Update to `FocusSession`
   - [ ] Search for `WorkoutStore` in tests → Update to `FocusStore`
   - [ ] Search for `WorkoutEngine` in tests → Update to `PomodoroEngine`
   - [ ] Search for `WorkoutTimer` in tests → Update to `FocusTimer`
   - [ ] Update all test assertions

5. **Run Tests**
   - [ ] Run all tests
   - [ ] Fix any failing tests
   - [ ] Ensure test coverage is maintained

### Files to Modify
- `FocusFlowTests/WorkoutEngineTests.swift` → Rename or DELETE
- `FocusFlowTests/WorkoutStoreTests.swift` → Rename or DELETE
- `FocusFlowTests/Mocks/MockWorkoutTimer.swift` → Rename or DELETE
- All test files using workout terminology

### Success Criteria
- [ ] All test files updated
- [ ] All tests pass
- [ ] No broken test references
- [ ] Test coverage maintained
- [ ] No compilation errors

---

## 📝 Agent 28: Update Terminology in Code

**Priority**: MEDIUM  
**Estimated Time**: 3-4 hours  
**Dependencies**: Agent 21-27 (all files must be refactored first)

### Tasks

1. **Search & Replace "workout" → "focus session"**
   - [ ] Search all Swift files for "workout" (case-insensitive)
   - [ ] Replace in comments, variable names, function names where appropriate
   - [ ] Be careful with HealthKit API (`HKWorkoutSession` - KEEP this)
   - [ ] Update variable names: `workoutStore` → `focusStore` (if any remain)
   - [ ] Update function parameters

2. **Search & Replace "exercise" → appropriate focus terminology**
   - [ ] Remove exercise references (no exercises in Pomodoro)
   - [ ] Replace with focus session terminology
   - [ ] Update comments

3. **Update Analytics Code**
   - [ ] Search for workout analytics → Update to focus analytics
   - [ ] Update `WorkoutSession` references → `FocusSession`
   - [ ] Update analytics method names
   - [ ] Update analytics data structures

4. **Update Achievement Code**
   - [ ] Search for workout achievements → Update to focus achievements
   - [ ] Update achievement names and descriptions
   - [ ] Update achievement criteria

5. **Update Notification Code**
   - [ ] Update workout notification categories → focus categories
   - [ ] Update notification messages
   - [ ] Update notification titles

6. **Update Motivation Code**
   - [ ] Update workout motivational messages → focus messages
   - [ ] Update quotes and tips
   - [ ] Update message templates

7. **Update HealthKit Code** (BE CAREFUL)
   - [ ] Keep `HKWorkoutSession` (HealthKit API - don't change)
   - [ ] Update comments to clarify it's for HealthKit API
   - [ ] Update workout type metadata → focus type
   - [ ] Update workout descriptions

### Files to Search & Update
- All Swift files in `FocusFlow/`
- Focus on:
  - Analytics files
  - Achievement files
  - Notification files
  - Motivation files
  - HealthKit files (carefully)

### Success Criteria
- [ ] No "workout" references in code (except HealthKit API)
- [ ] No "exercise" references in code
- [ ] All terminology consistent
- [ ] Code still compiles
- [ ] HealthKit API references preserved

---

## 🎨 Agent 29: Update User-Facing Strings

**Priority**: LOW  
**Estimated Time**: 2-3 hours  
**Dependencies**: Agent 28 (code terminology must be updated first)

### Tasks

1. **Update Settings Strings**
   - [ ] Update "workout" → "focus session" in Settings UI
   - [ ] Update "workout reminders" → "focus reminders"
   - [ ] Update "workout history" → "focus history"
   - [ ] Update "workout preferences" → "focus preferences"
   - [ ] Update all user-facing text in Settings

2. **Update Notification Strings**
   - [ ] Update notification titles
   - [ ] Update notification messages
   - [ ] Update notification categories
   - [ ] Update notification actions

3. **Update Motivation Strings**
   - [ ] Update motivational messages
   - [ ] Update achievement descriptions
   - [ ] Update tips and quotes
   - [ ] Update encouragement messages

4. **Update Empty State Messages**
   - [ ] Update empty state messages from workout → focus
   - [ ] Update empty state icons if needed
   - [ ] Update empty state actions

5. **Update Help & FAQ**
   - [ ] Update help text from workout → focus
   - [ ] Update FAQ questions and answers
   - [ ] Update tutorial text

6. **Update Error Messages**
   - [ ] Update error messages from workout → focus
   - [ ] Update error descriptions

### Files to Modify
- `FocusFlow/SettingsView.swift`
- `FocusFlow/Notifications/NotificationManager.swift`
- `FocusFlow/Motivation/MotivationalMessageManager.swift`
- `FocusFlow/UI/States/EmptyStates.swift`
- `FocusFlow/Views/Help/FAQView.swift`
- `FocusFlow/Views/Help/HelpView.swift`
- `FocusFlow/UI/ErrorHandling.swift`
- Any other files with user-facing strings

### Success Criteria
- [ ] All user-facing strings updated
- [ ] No "workout" in UI text
- [ ] No "exercise" in UI text
- [ ] App tested to verify strings display correctly
- [ ] Localization strings updated (if applicable)

---

## ✅ Agent 30: Final Project Cleanup & Verification

**Priority**: HIGH  
**Estimated Time**: 1-2 hours  
**Dependencies**: All previous agents (21-29)

### Tasks

1. **Update project.pbxproj**
   - [ ] Remove all deleted files from project.pbxproj
   - [ ] Add any new files that were created
   - [ ] Update file references
   - [ ] Clean up build phases
   - [ ] Remove unused targets (if any)

2. **Verify No Broken References**
   - [ ] Search entire codebase for "WorkoutStore"
   - [ ] Search for "WorkoutSession"
   - [ ] Search for "WorkoutEngine"
   - [ ] Search for "WorkoutTimer"
   - [ ] Search for "WorkoutShareManager"
   - [ ] Search for "WorkoutWidget"
   - [ ] Fix any remaining references

3. **Build & Test**
   - [ ] Clean build folder
   - [ ] Build project
   - [ ] Fix any compilation errors
   - [ ] Run all tests
   - [ ] Test app functionality
   - [ ] Test on simulator
   - [ ] Test on device (if possible)

4. **Code Quality Check**
   - [ ] Run linter
   - [ ] Fix any warnings
   - [ ] Check for unused imports
   - [ ] Check for unused code
   - [ ] Verify code formatting

5. **Documentation Update**
   - [ ] Update README.md if needed
   - [ ] Update any agent completion docs
   - [ ] Document what was removed
   - [ ] Document what was refactored

6. **Final Verification**
   - [ ] Count remaining "workout" references (should be 0, except HealthKit API)
   - [ ] Count remaining "exercise" references (should be 0)
   - [ ] Verify all focus terminology is consistent
   - [ ] Create final cleanup report

### Files to Check
- `FocusFlow.xcodeproj/project.pbxproj`
- All Swift files
- All configuration files

### Success Criteria
- [ ] Project builds successfully
- [ ] All tests pass
- [ ] Zero "workout" references (except HealthKit API)
- [ ] Zero "exercise" references
- [ ] No broken references
- [ ] No linter errors
- [ ] App functions correctly
- [ ] Cleanup report created

---

## 📊 Agent Summary

| Agent | Status | Priority | Dependencies |
|-------|--------|----------|--------------|
| **Agent 21** | 🔴 Not Started | CRITICAL | None |
| **Agent 22** | 🔴 Not Started | HIGH | Agent 21 |
| **Agent 23** | 🔴 Not Started | HIGH | Agent 21 |
| **Agent 24** | 🔴 Not Started | MEDIUM | None |
| **Agent 25** | 🔴 Not Started | MEDIUM | Agent 21, 23 |
| **Agent 26** | 🔴 Not Started | HIGH | Agent 21, 22 |
| **Agent 27** | 🔴 Not Started | MEDIUM | Agent 21, 22, 26 |
| **Agent 28** | 🔴 Not Started | MEDIUM | Agent 21-27 |
| **Agent 29** | 🔴 Not Started | LOW | Agent 28 |
| **Agent 30** | 🔴 Not Started | HIGH | All (21-29) |

**Legend**:  
🔴 Not Started | 🟡 In Progress | 🟢 Completed

---

## 🚦 Execution Order

### Phase 1: Critical Fixes (Must Do First)
1. **Agent 21** - Fix RootView & Settings (CRITICAL)

### Phase 2: Core Cleanup (High Priority)
2. **Agent 22** - Delete Workout Views & Models
3. **Agent 23** - Refactor WorkoutShareManager
4. **Agent 26** - Delete Workout Directory Files

### Phase 3: Supporting Cleanup (Medium Priority)
5. **Agent 24** - Refactor Widget & Shortcuts
6. **Agent 25** - Update Export & Sharing Code
7. **Agent 27** - Update Test Files

### Phase 4: Final Polish (Lower Priority)
8. **Agent 28** - Update Terminology in Code
9. **Agent 29** - Update User-Facing Strings

### Phase 5: Verification (Final Step)
10. **Agent 30** - Final Project Cleanup & Verification

---

## ⚠️ Important Notes

1. **HealthKit API**: `HKWorkoutSession` is a HealthKit API class - DO NOT rename this. Only update comments and metadata.

2. **Dependencies**: Follow the execution order - some agents depend on others.

3. **Testing**: Test after each agent to ensure nothing breaks.

4. **Git**: Commit after each agent completes for easy rollback.

5. **Backup**: Create a git commit before starting Agent 21.

---

## 📝 Completion Checklist

Before marking any agent complete, verify:
- [ ] All tasks completed
- [ ] Code compiles
- [ ] Tests pass (if applicable)
- [ ] Functionality works
- [ ] No broken references
- [ ] Success criteria met

