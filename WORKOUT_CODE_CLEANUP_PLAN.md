# Workout Code Cleanup Plan - Complete Removal of Workout References

## 🎯 Goal
Remove all workout-related code and terminology from the FocusFlow codebase, ensuring the app is fully focused on Pomodoro timer functionality.

## 📊 Current State Analysis

### Workout-Related Files Found
1. **Workout Directory** (`FocusFlow/Workout/`)
   - `WorkoutEngine.swift` - Core workout engine (replace with PomodoroEngine ✅)
   - `WorkoutTimer.swift` - Timer implementation (replace with FocusTimer ✅)
   - `FormFeedbackSystem.swift` - Exercise form feedback (DELETE)
   - `RepCounter.swift` - Rep counting (DELETE)
   - `VoiceCuesManager.swift` - Workout voice cues (DELETE)
   - `SegmentedProgressRing.swift` - Exercise progress ring (KEEP - may be useful)

2. **Sharing Files**
   - `WorkoutShareManager.swift` - Should become `FocusShareManager.swift`
   - `ShareImageGenerator.swift` - Has workout completion methods (REFACTOR)
   - `PosterExporter.swift` - Has workout completion methods (REFACTOR)
   - `PosterRenderer.swift` - May have workout references (CHECK)

3. **Widget Files**
   - `WorkoutWidget.swift` - Should become `FocusWidget.swift`

4. **Shortcuts**
   - `WorkoutShortcuts.swift` - Should become `FocusShortcuts.swift`
   - `FocusShortcuts.swift` - Already exists (CHECK for duplicates)

5. **History Views**
   - `WorkoutHistoryView.swift` - DELETE (FocusHistoryView exists ✅)
   - `WorkoutHistoryRow.swift` - DELETE (FocusHistoryRow exists ✅)
   - `WorkoutHistoryFilterView.swift` - DELETE (FocusHistoryFilterView exists ✅)

6. **Models**
   - `WorkoutSession.swift` - DELETE (FocusSession exists ✅)
   - `WorkoutStore.swift` - DELETE (FocusStore exists ✅)
   - `Exercise.swift` - DELETE
   - `CustomWorkout.swift` - DELETE
   - `WorkoutPreset.swift` - DELETE (PomodoroPreset exists ✅)
   - `WorkoutPreferencesStore.swift` - DELETE (FocusPreferencesStore exists ✅)

7. **Test Files**
   - `WorkoutEngineTests.swift` - Should become `PomodoroEngineTests.swift` or DELETE
   - `WorkoutStoreTests.swift` - Should become `FocusStoreTests.swift` or DELETE
   - `MockWorkoutTimer.swift` - Should become `MockFocusTimer.swift` or DELETE

8. **Other Files**
   - `ExerciseListView.swift` - DELETE (no exercises in Pomodoro)
   - `WorkoutCustomizationView.swift` - DELETE or REFACTOR to FocusCustomizationView
   - `WorkoutTemplateManager.swift` - DELETE or REFACTOR
   - `ExerciseSelectorView.swift` - DELETE
   - `FirstWorkoutTutorialView.swift` - DELETE (FirstFocusTutorialView exists ✅)
   - `FitnessLevelAssessmentView.swift` - DELETE (not needed for Pomodoro)

## 🔍 Dependency Analysis

### Files Still Using Workout Code
1. **RootView.swift** - May reference WorkoutViews
2. **SettingsView.swift** - May have workout preferences
3. **HealthKitManager.swift** - Uses HKWorkoutSession (KEEP - HealthKit API)
4. **Analytics** - May reference workout sessions
5. **Achievements** - May have workout achievements
6. **Notifications** - May have workout reminders
7. **Motivation** - May have workout messages

## 📋 Cleanup Plan

### Phase 1: Identify and Document (✅ Complete)
- [x] Identify all workout-related files
- [x] Document dependencies
- [x] Create cleanup plan

### Phase 2: Remove Dead Code (Low Risk)
**Priority: HIGH - Safe Deletions**

#### 2.1 Delete Workout Directory Files
- [ ] Delete `FocusFlow/Workout/FormFeedbackSystem.swift`
- [ ] Delete `FocusFlow/Workout/RepCounter.swift`
- [ ] Delete `FocusFlow/Workout/VoiceCuesManager.swift`
- [ ] Delete `FocusFlow/Workout/WorkoutEngine.swift` (if PomodoroEngine exists ✅)
- [ ] Delete `FocusFlow/Workout/WorkoutTimer.swift` (if FocusTimer exists ✅)
- [ ] Delete `FocusFlow/Workout/SegmentedProgressRing.swift` (if not needed)
- [ ] Delete `FocusFlow/Workout/` directory if empty

#### 2.2 Delete Workout Models
- [ ] Delete `FocusFlow/Models/WorkoutSession.swift`
- [ ] Delete `FocusFlow/Models/WorkoutStore.swift`
- [ ] Delete `FocusFlow/Models/Exercise.swift`
- [ ] Delete `FocusFlow/Models/CustomWorkout.swift`
- [ ] Delete `FocusFlow/Models/WorkoutPreset.swift`
- [ ] Delete `FocusFlow/Models/WorkoutPreferencesStore.swift`

#### 2.3 Delete Workout Views
- [ ] Delete `FocusFlow/Views/History/WorkoutHistoryView.swift`
- [ ] Delete `FocusFlow/Views/History/WorkoutHistoryRow.swift`
- [ ] Delete `FocusFlow/Views/History/WorkoutHistoryFilterView.swift`
- [ ] Delete `FocusFlow/Views/Exercises/ExerciseListView.swift`
- [ ] Delete `FocusFlow/Views/Customization/ExerciseSelectorView.swift`
- [ ] Delete `FocusFlow/Views/Customization/WorkoutCustomizationView.swift` (or refactor)
- [ ] Delete `FocusFlow/Views/Customization/WorkoutTemplateManager.swift` (or refactor)
- [ ] Delete `FocusFlow/Onboarding/FirstWorkoutTutorialView.swift`
- [ ] Delete `FocusFlow/Onboarding/FitnessLevelAssessmentView.swift`
- [ ] Delete `FocusFlow/Views/Exercises/` directory if empty

### Phase 3: Refactor Active Code (Medium Risk)
**Priority: HIGH - Core Functionality**

#### 3.1 Rename Core Files
- [ ] Rename `WorkoutShareManager.swift` → `FocusShareManager.swift`
- [ ] Rename `WorkoutWidget.swift` → `FocusWidget.swift`
- [ ] Rename `WorkoutShortcuts.swift` → Delete (if FocusShortcuts exists)
- [ ] Update all imports and references

#### 3.2 Refactor Sharing Code
- [ ] Refactor `WorkoutShareManager` class → `FocusShareManager`
- [ ] Update `shareWorkoutCompletion` → `shareFocusSession`
- [ ] Update `ShareImageGenerator.generateWorkoutCompletionImage` → `generateFocusCompletionImage`
- [ ] Update `PosterExporter` workout methods → focus methods
- [ ] Update sharing text from "workout" → "focus session"

#### 3.3 Update RootView
- [ ] Remove `WorkoutContentView` references
- [ ] Remove `WorkoutHistoryView` references
- [ ] Ensure only `FocusContentView` and `FocusHistoryView` are used
- [ ] Remove `WorkoutStore` environment objects
- [ ] Ensure only `FocusStore` is used

### Phase 4: Update Terminology (Medium Risk)
**Priority: MEDIUM - User-Facing**

#### 4.1 Update Settings
- [ ] Replace "workout" terminology with "focus session"
- [ ] Update workout preferences → focus preferences
- [ ] Update workout reminders → focus reminders
- [ ] Update workout history → focus history

#### 4.2 Update Analytics
- [ ] Update `WorkoutSession` references → `FocusSession`
- [ ] Update workout analytics → focus analytics
- [ ] Update workout achievements → focus achievements
- [ ] Update workout streaks → focus streaks

#### 4.3 Update Notifications
- [ ] Update workout reminder messages
- [ ] Update workout notification categories
- [ ] Update workout achievement notifications

#### 4.4 Update Motivation
- [ ] Update workout motivational messages
- [ ] Update workout quotes
- [ ] Update workout tips

### Phase 5: Update Tests (Low Risk)
**Priority: MEDIUM - Testing**

#### 5.1 Update Test Files
- [ ] Rename `WorkoutEngineTests.swift` → `PomodoroEngineTests.swift` or DELETE
- [ ] Rename `WorkoutStoreTests.swift` → `FocusStoreTests.swift` or DELETE
- [ ] Rename `MockWorkoutTimer.swift` → `MockFocusTimer.swift` or DELETE
- [ ] Update all test imports
- [ ] Update all test references to workout code
- [ ] Ensure tests still pass

#### 5.2 Update Test Mocks
- [ ] Update `MockWorkoutTimer` → `MockFocusTimer`
- [ ] Update all test mocks to use focus terminology

### Phase 6: Update Documentation (Low Risk)
**Priority: LOW - Documentation**

#### 6.1 Update Code Comments
- [ ] Update all code comments mentioning "workout"
- [ ] Update all code comments mentioning "exercise"
- [ ] Update all code comments mentioning "workout session"

#### 6.2 Update Documentation Files
- [ ] Update README.md
- [ ] Update any agent completion docs
- [ ] Update any refactor plans

### Phase 7: Clean Up Project File (Low Risk)
**Priority: MEDIUM - Build System**

#### 7.1 Update Xcode Project
- [ ] Remove deleted files from project.pbxproj
- [ ] Remove workout-related targets (if any)
- [ ] Update build phases
- [ ] Clean up references

## 🚨 Critical Path Items

### Must Do First (Blocking)
1. **Update RootView** - Ensure it only uses Focus views
2. **Update Sharing** - Refactor WorkoutShareManager
3. **Update Widget** - Rename WorkoutWidget
4. **Remove Workout Models** - Delete WorkoutStore, WorkoutSession
5. **Remove Workout Views** - Delete WorkoutHistoryView

### Can Do After (Non-Blocking)
1. Update terminology in Settings
2. Update analytics terminology
3. Update test files
4. Update documentation

## ⚠️ Risk Assessment

### High Risk (Test Thoroughly)
- Removing WorkoutStore/WorkoutSession if still referenced
- Refactoring WorkoutShareManager
- Updating RootView
- Removing Workout Engine/Timer

### Medium Risk (Test)
- Renaming files
- Updating terminology
- Updating tests

### Low Risk (Safe)
- Deleting unused files
- Updating documentation
- Updating code comments

## 📝 Implementation Checklist

### Step 1: Backup & Verify
- [ ] Create git commit before starting
- [ ] Verify all Focus models/views exist and work
- [ ] Run tests to ensure baseline is good

### Step 2: Remove Dead Code
- [ ] Delete workout directory files
- [ ] Delete workout models
- [ ] Delete workout views
- [ ] Remove from project.pbxproj

### Step 3: Refactor Active Code
- [ ] Rename WorkoutShareManager → FocusShareManager
- [ ] Rename WorkoutWidget → FocusWidget
- [ ] Update RootView
- [ ] Update all imports

### Step 4: Update Terminology
- [ ] Replace "workout" with "focus session" in code
- [ ] Replace "exercise" with appropriate focus terminology
- [ ] Update user-facing strings

### Step 5: Test & Verify
- [ ] Build project
- [ ] Run tests
- [ ] Test app functionality
- [ ] Verify no broken references

### Step 6: Clean Up
- [ ] Remove unused imports
- [ ] Update documentation
- [ ] Commit changes

## 🎯 Success Criteria

- [ ] Zero "workout" references in active code (except HealthKit API)
- [ ] Zero "exercise" references in active code
- [ ] All workout files deleted
- [ ] All focus terminology consistent
- [ ] App builds successfully
- [ ] All tests pass
- [ ] App functions correctly

## 📊 Estimated Effort

- **Phase 2 (Delete Dead Code)**: 2-3 hours
- **Phase 3 (Refactor Active Code)**: 4-6 hours
- **Phase 4 (Update Terminology)**: 3-4 hours
- **Phase 5 (Update Tests)**: 2-3 hours
- **Phase 6 (Documentation)**: 1-2 hours
- **Phase 7 (Project Cleanup)**: 1 hour

**Total Estimated Time**: 13-19 hours

## 🔄 Rollback Plan

If issues arise:
1. Revert to git commit before cleanup
2. Review what broke
3. Fix issues incrementally
4. Re-test after each fix

