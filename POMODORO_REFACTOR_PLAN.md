# 🍅 Pomodoro Timer: Focus & Study - 8-Agent Refactor Plan

## Overview
This document outlines a comprehensive 8-agent refactoring plan to transform Ritual7 (7-minute workout app) into **Pomodoro Timer: Focus & Study** - a beautiful, productivity-focused Pomodoro timer app optimized for interstitial ad monetization and organic traffic.

---

## 🎯 Project Goals

### Primary Objectives
1. **Refactor Core Functionality**: Convert workout timer → Pomodoro focus timer
2. **Rebrand & Redesign**: Update all UI/UX for productivity/focus theme
3. **Monetization**: Optimize interstitial ad placement for natural break points
4. **Organic Traffic**: Optimize for App Store keywords (pomodoro, focus timer, study timer)
5. **Maintain Quality**: Preserve existing architecture, analytics, and polish

### Key Features to Implement
- Classic Pomodoro: 25 min focus / 5 min break
- Custom timer intervals
- Pomodoro cycles (4 sessions = long break)
- Focus session tracking
- Daily/weekly focus statistics
- Streak tracking
- Apple Watch companion
- Beautiful, distraction-free UI

---

## 📋 Agent Assignments

### **Agent 1: Core Timer Engine Refactoring**
**Goal:** Refactor workout timer infrastructure into Pomodoro timer engine

**Tasks:**

1. **Refactor WorkoutEngine → PomodoroEngine**
   - Convert `WorkoutEngine.swift` → `PomodoroEngine.swift`
   - Replace exercise phases with focus/break phases
   - Implement Pomodoro cycle logic (4 sessions = long break)
   - Add focus session state management
   - Maintain pause/resume functionality
   - Keep timer precision (0.1s updates)

2. **Refactor WorkoutTimer → FocusTimer**
   - Rename `WorkoutTimer.swift` → `FocusTimer.swift`
   - Update timer callbacks for focus/break phases
   - Maintain existing timer accuracy and pause/resume logic
   - Add support for multiple timer modes (focus, short break, long break)

3. **Update Timer Views**
   - Refactor `WorkoutTimerView.swift` → `FocusTimerView.swift`
   - Remove exercise-specific UI elements
   - Add focus/break phase indicators
   - Update progress ring for focus sessions
   - Add Pomodoro cycle progress (1/4, 2/4, etc.)

4. **Remove Workout-Specific Code**
   - Remove exercise-related logic
   - Remove exercise animations
   - Remove rep counting
   - Remove form feedback systems
   - Clean up unused workout utilities

**Files to Modify:**
- `Ritual7/Workout/WorkoutEngine.swift` → `Ritual7/Focus/PomodoroEngine.swift`
- `Ritual7/Workout/WorkoutTimer.swift` → `Ritual7/Focus/FocusTimer.swift`
- `Ritual7/Workout/WorkoutTimerView.swift` → `Ritual7/Focus/FocusTimerView.swift`
- `Ritual7/Workout/WorkoutContentView.swift` → `Ritual7/Focus/FocusContentView.swift`
- Delete: `ExerciseAnimations.swift`, `RepCounter.swift`, `FormFeedbackSystem.swift`, `VoiceCuesManager.swift`

**Files to Create:**
- `Ritual7/Focus/PomodoroEngine.swift`
- `Ritual7/Focus/FocusTimer.swift`
- `Ritual7/Focus/FocusTimerView.swift`
- `Ritual7/Focus/FocusContentView.swift`
- `Ritual7/Focus/PomodoroCycleManager.swift`

**Success Criteria:**
- ✅ Timer works for 25/5/15 minute intervals
- ✅ Pomodoro cycle logic (4 sessions = long break) works correctly
- ✅ Pause/resume functionality maintained
- ✅ Background/foreground handling works
- ✅ All workout-specific code removed
- ✅ Zero compilation errors

---

### **Agent 2: Models & Data Layer Refactoring**
**Goal:** Refactor data models from workout sessions to focus sessions

**Tasks:**

1. **Refactor WorkoutSession → FocusSession**
   - Convert `WorkoutSession.swift` → `FocusSession.swift`
   - Replace workout metrics with focus metrics
   - Track: duration, completion status, phase type (focus/break)
   - Remove exercise-specific data
   - Add Pomodoro cycle tracking

2. **Refactor WorkoutStore → FocusStore**
   - Convert `WorkoutStore.swift` → `FocusStore.swift`
   - Update persistence layer for focus sessions
   - Replace workout statistics with focus statistics
   - Track: daily focus time, completed sessions, streaks
   - Maintain same data persistence approach (UserDefaults/CoreData)

3. **Refactor Exercise Model (Remove/Replace)**
   - Remove `Exercise.swift` model
   - Create `PomodoroPreset.swift` for timer presets:
     - Classic: 25/5/15
     - Deep Work: 45/15/30
     - Short Sprints: 15/3/15
     - Custom intervals

4. **Update Preferences Store**
   - Refactor `WorkoutPreferencesStore.swift` → `FocusPreferencesStore.swift`
   - Store: focus duration, short break, long break, cycle length
   - Store: sound preferences, haptics, notifications
   - Store: auto-start breaks, auto-start next session

5. **Remove Custom Workout Models**
   - Remove `CustomWorkout.swift`
   - Remove `WorkoutPreset.swift`
   - Replace with `PomodoroPreset.swift`

**Files to Modify:**
- `Ritual7/Models/WorkoutSession.swift` → `Ritual7/Models/FocusSession.swift`
- `Ritual7/Models/WorkoutStore.swift` → `Ritual7/Models/FocusStore.swift`
- `Ritual7/Models/WorkoutPreferencesStore.swift` → `Ritual7/Models/FocusPreferencesStore.swift`
- Delete: `Ritual7/Models/Exercise.swift`, `Ritual7/Models/CustomWorkout.swift`, `Ritual7/Models/WorkoutPreset.swift`

**Files to Create:**
- `Ritual7/Models/FocusSession.swift`
- `Ritual7/Models/FocusStore.swift`
- `Ritual7/Models/FocusPreferencesStore.swift`
- `Ritual7/Models/PomodoroPreset.swift`
- `Ritual7/Models/PomodoroCycle.swift`

**Success Criteria:**
- ✅ All data models refactored for focus sessions
- ✅ Data persistence works correctly
- ✅ Statistics tracking functional
- ✅ Preferences stored and loaded correctly
- ✅ No workout-specific models remain

---

### **Agent 3: UI/UX Rebranding & Design System**
**Goal:** Redesign all UI for productivity/focus theme with beautiful, distraction-free design

**Tasks:**

1. **Update Design System**
   - Review `UI/Theme.swift` and `UI/ThemeStore.swift`
   - Update color palette for focus/productivity theme
   - Consider: calm blues, greens, or warm neutrals
   - Maintain glassmorphism design language
   - Update typography for readability during focus

2. **Refactor Main Views**
   - Update `RootView.swift` navigation structure
   - Replace tabs: Focus → History → Stats → Settings
   - Remove workout-specific tabs
   - Update `HeroWorkoutCard.swift` → `HeroFocusCard.swift`
   - Redesign main focus screen for minimal distraction

3. **Create Focus-Specific UI Components**
   - Create `FocusPhaseIndicator.swift` (Focus/Break/Long Break)
   - Create `PomodoroCycleProgressView.swift` (1/4, 2/4, 3/4, 4/4)
   - Create `FocusSessionCard.swift` for history
   - Update `CompletionCelebrationView.swift` → `SessionCompleteView.swift`
   - Add motivational quotes during breaks

4. **Update Progress Visualizations**
   - Refactor progress views for focus time tracking
   - Update calendar heatmap for daily focus sessions
   - Create focus streak visualization
   - Update charts for focus statistics (not workouts)

5. **Remove Workout-Specific UI**
   - Remove `ExerciseGuideView.swift`
   - Remove `BreathingGuideView.swift`
   - Remove exercise-related animations
   - Clean up workout-specific UI components

**Files to Modify:**
- `Ritual7/RootView.swift`
- `Ritual7/UI/Theme.swift`
- `Ritual7/UI/ThemeStore.swift`
- `Ritual7/Workout/HeroWorkoutCard.swift` → `Ritual7/Focus/HeroFocusCard.swift`
- `Ritual7/Workout/CompletionCelebrationView.swift` → `Ritual7/Focus/SessionCompleteView.swift`
- `Ritual7/Views/Progress/` (all files - refactor for focus stats)

**Files to Create:**
- `Ritual7/Focus/FocusPhaseIndicator.swift`
- `Ritual7/Focus/PomodoroCycleProgressView.swift`
- `Ritual7/Focus/FocusSessionCard.swift`
- `Ritual7/Focus/SessionCompleteView.swift`
- `Ritual7/Focus/MotivationalQuotesView.swift`

**Files to Delete:**
- `Ritual7/Workout/ExerciseGuideView.swift`
- `Ritual7/Workout/BreathingGuideView.swift`
- `Ritual7/Views/Exercises/` (entire directory)

**Success Criteria:**
- ✅ Beautiful, distraction-free focus UI
- ✅ Consistent design system throughout
- ✅ All workout-specific UI removed
- ✅ Focus theme applied consistently
- ✅ Smooth animations and transitions

---

### **Agent 4: Analytics & Insights Refactoring**
**Goal:** Refactor analytics system from workout tracking to focus session analytics

**Tasks:**

1. **Refactor Analytics Managers**
   - Update `WorkoutAnalytics.swift` → `FocusAnalytics.swift`
   - Track: daily focus time, completed sessions, streaks
   - Track: best focus times of day, weekly patterns
   - Track: average session duration, completion rate
   - Remove workout-specific metrics

2. **Update Achievement System**
   - Refactor `AchievementManager.swift` for focus achievements
   - Create new achievements:
     - First Focus Session
     - 7-Day Streak
     - 30-Day Streak
     - 100 Sessions Completed
     - Perfect Week (daily sessions)
     - Early Bird (morning focus)
     - Night Owl (evening focus)
     - Deep Focus (completed 4-session cycle)
   - Update achievement notifications

3. **Refactor Progress Charts**
   - Update `Views/Progress/` directory
   - Replace workout charts with focus time charts
   - Update calendar heatmap for focus sessions
   - Create weekly/monthly focus time trends
   - Update streak visualization

4. **Update Insights & Recommendations**
   - Refactor `TrendAnalyzer.swift` for focus patterns
   - Update `PredictiveAnalytics.swift` for focus predictions
   - Create focus insights: "You focus best in the morning"
   - Add productivity tips and recommendations

5. **Update History Views**
   - Refactor `Views/History/` directory
   - Update session detail view for focus sessions
   - Show: duration, phase type, completion status
   - Update filtering and search

**Files to Modify:**
- `Ritual7/Analytics/WorkoutAnalytics.swift` → `Ritual7/Analytics/FocusAnalytics.swift`
- `Ritual7/Analytics/AchievementManager.swift`
- `Ritual7/Analytics/TrendAnalyzer.swift`
- `Ritual7/Analytics/PredictiveAnalytics.swift`
- `Ritual7/Views/History/` (all files)
- `Ritual7/Views/Progress/` (all files)

**Files to Create:**
- `Ritual7/Analytics/FocusAnalytics.swift`
- `Ritual7/Analytics/FocusInsightsManager.swift`

**Success Criteria:**
- ✅ All analytics track focus sessions correctly
- ✅ Achievements system updated for focus
- ✅ Progress charts show focus statistics
- ✅ Insights provide valuable productivity feedback
- ✅ History views work for focus sessions

---

### **Agent 5: Apple Watch App Refactoring**
**Goal:** Refactor Apple Watch app from workout companion to Pomodoro focus timer

**Tasks:**

1. **Refactor Watch App Structure**
   - Update `Ritual7Watch/` directory structure
   - Rename workout-related files to focus-related
   - Update bundle identifier if needed
   - Update Watch app name/display name

2. **Refactor Watch Timer Views**
   - Update `WorkoutEngineWatch.swift` → `PomodoroEngineWatch.swift`
   - Update Watch timer UI for focus/break phases
   - Show: current phase, time remaining, cycle progress
   - Maintain haptic feedback for phase transitions
   - Update complications for focus sessions

3. **Update Watch Complications**
   - Update complications to show:
     - Current focus streak
     - Today's focus time
     - Quick start button
   - Remove workout-specific complications

4. **Update Watch Sync**
   - Ensure `WatchSessionManager.swift` works with focus sessions
   - Sync focus session data between iPhone and Watch
   - Update session completion sync

**Files to Modify:**
- `Ritual7Watch/` (all files - refactor for focus)
- `Ritual7/System/WatchSessionManager.swift`

**Files to Create:**
- `Ritual7Watch/Focus/PomodoroEngineWatch.swift`
- `Ritual7Watch/Focus/FocusTimerViewWatch.swift`

**Success Criteria:**
- ✅ Watch app shows focus timer correctly
- ✅ Phase transitions work (focus/break)
- ✅ Complications updated for focus
- ✅ Sync between iPhone and Watch works
- ✅ Haptic feedback functional

---

### **Agent 6: Settings & Customization**
**Goal:** Create comprehensive settings and customization for Pomodoro timer

**Tasks:**

1. **Refactor Settings View**
   - Update `SettingsView.swift` for Pomodoro settings
   - Add timer presets selection
   - Add custom interval configuration
   - Add sound/haptic preferences
   - Add notification preferences
   - Add auto-start settings

2. **Create Timer Presets**
   - Classic Pomodoro: 25/5/15 (default)
   - Deep Work: 45/15/30
   - Short Sprints: 15/3/15
   - Custom: User-defined intervals
   - Allow users to save custom presets

3. **Update Customization Views**
   - Refactor `Views/Customization/` directory
   - Remove workout customization
   - Add Pomodoro preset configuration
   - Add interval duration settings
   - Add cycle length settings (sessions before long break)

4. **Add Focus Features**
   - Focus mode integration (iOS Focus Mode)
   - Do Not Disturb integration
   - Background audio during focus
   - White noise/ambient sounds option
   - Motivational quotes during breaks

5. **Update Notifications**
   - Refactor `NotificationManager.swift` for focus reminders
   - Add: Daily focus reminders
   - Add: Break reminders
   - Add: Streak maintenance reminders
   - Update notification content for focus theme

**Files to Modify:**
- `Ritual7/SettingsView.swift`
- `Ritual7/Notifications/NotificationManager.swift`
- `Ritual7/Views/Customization/` (all files)

**Files to Create:**
- `Ritual7/Focus/PomodoroPresetManager.swift`
- `Ritual7/Focus/FocusModeIntegration.swift`
- `Ritual7/Focus/AmbientSoundsManager.swift`

**Success Criteria:**
- ✅ Settings view fully functional
- ✅ Timer presets work correctly
- ✅ Custom intervals can be configured
- ✅ Notifications work for focus reminders
- ✅ Focus mode integration works

---

### **Agent 7: Onboarding & Education**
**Goal:** Create onboarding flow and educational content about Pomodoro Technique

**Tasks:**

1. **Create Onboarding Flow**
   - Update `Onboarding/OnboardingView.swift` for Pomodoro app
   - Create onboarding steps:
     - Welcome screen
     - Pomodoro Technique explanation
     - Timer preset selection
     - Notification permissions
     - First focus session prompt
   - Update `OnboardingManager.swift`

2. **Create Pomodoro Guide**
   - Create `PomodoroGuideView.swift`
   - Explain Pomodoro Technique
   - Explain: 25 min focus, 5 min break, 15 min long break
   - Explain: 4-session cycles
   - Add tips for effective focus
   - Add productivity tips

3. **Update Help Center**
   - Refactor `Help/HelpCenterView.swift` for focus app
   - Update help content for Pomodoro timer
   - Add FAQ section
   - Add troubleshooting guide

4. **Create First Session Tutorial**
   - Update `Onboarding/FirstWorkoutTutorialView.swift` → `Onboarding/FirstFocusTutorialView.swift`
   - Guide users through first focus session
   - Explain timer controls
   - Explain phase transitions

5. **Add Productivity Tips**
   - Create tips system for breaks
   - Add motivational quotes
   - Add productivity advice
   - Show tips during short breaks

**Files to Modify:**
- `Ritual7/Onboarding/OnboardingView.swift`
- `Ritual7/Onboarding/OnboardingManager.swift`
- `Ritual7/Onboarding/FirstWorkoutTutorialView.swift` → `Ritual7/Onboarding/FirstFocusTutorialView.swift`
- `Ritual7/Help/HelpCenterView.swift`

**Files to Create:**
- `Ritual7/Focus/PomodoroGuideView.swift`
- `Ritual7/Focus/ProductivityTipsManager.swift`
- `Ritual7/Focus/MotivationalQuotesManager.swift`

**Success Criteria:**
- ✅ Onboarding flow guides new users
- ✅ Pomodoro Technique explained clearly
- ✅ First session tutorial helpful
- ✅ Help center updated for focus app
- ✅ Educational content engaging

---

### **Agent 8: Final Polish, Interstitial Ads, & App Store Prep**
**Goal:** Final polish, optimize ad placement, prepare for App Store submission

**Tasks:**

1. **Optimize Interstitial Ad Placement**
   - Update `InterstitialAdManager.swift` integration
   - Add ads after focus session completion (natural break)
   - Add ads after break completion
   - Add ads after viewing statistics
   - Ensure ads don't interrupt active focus sessions
   - Test ad frequency and timing

2. **Update App Metadata**
   - Update `Info.plist` with new app name
   - Update bundle identifier (if needed)
   - Update app icon and assets
   - Update launch screen
   - Update app display name

3. **Create App Store Assets**
   - Update `AppStore/AppStoreDescription.md` for Pomodoro app
   - Create new App Store description
   - Optimize keywords: pomodoro, focus timer, study timer, productivity
   - Create new screenshots
   - Update privacy policy (if needed)

4. **Remove HealthKit Integration (Optional)**
   - Decide if HealthKit integration is needed for focus app
   - If not needed, remove HealthKit code
   - If keeping, update for focus time tracking

5. **Final Testing & Bug Fixes**
   - Comprehensive testing of all features
   - Test timer accuracy
   - Test background/foreground handling
   - Test Watch sync
   - Test notifications
   - Fix any bugs or issues

6. **Performance Optimization**
   - Ensure smooth 60fps performance
   - Optimize battery usage
   - Test on multiple devices
   - Test on different iOS versions

7. **Accessibility Audit**
   - Ensure VoiceOver support
   - Test Dynamic Type
   - Test high contrast mode
   - Test reduced motion
   - Ensure all UI accessible

8. **Update Documentation**
   - Update `README.md` for Pomodoro app
   - Update project documentation
   - Update code comments
   - Create user guide

**Files to Modify:**
- `Ritual7/Info.plist`
- `Ritual7/Ritual7App.swift`
- `Ritual7/LaunchScreen.swift`
- `Ritual7/Monetization/InterstitialAdManager.swift`
- `AppStore/AppStoreDescription.md`
- `AppStore/Keywords.txt`
- `README.md`
- All files with workout references

**Files to Review:**
- `Ritual7/Health/` (decide if needed for focus app)
- All analytics and tracking code

**Success Criteria:**
- ✅ Interstitial ads placed optimally
- ✅ App metadata updated
- ✅ App Store assets ready
- ✅ All tests passing
- ✅ Zero critical bugs
- ✅ Performance optimized
- ✅ Accessibility verified
- ✅ Ready for App Store submission

---

## 🎯 Implementation Priority

### Phase 1: Core Refactoring (Week 1-2)
- **Agent 1**: Core Timer Engine Refactoring
- **Agent 2**: Models & Data Layer Refactoring

### Phase 2: UI & Features (Week 3-4)
- **Agent 3**: UI/UX Rebranding & Design System
- **Agent 4**: Analytics & Insights Refactoring

### Phase 3: Platform & Customization (Week 5-6)
- **Agent 5**: Apple Watch App Refactoring
- **Agent 6**: Settings & Customization

### Phase 4: Polish & Launch (Week 7-8)
- **Agent 7**: Onboarding & Education
- **Agent 8**: Final Polish, Ads, & App Store Prep

---

## 📊 Success Metrics

### Technical Metrics
- ✅ Zero compilation errors
- ✅ All tests passing
- ✅ Smooth 60fps performance
- ✅ < 2 second app launch time
- ✅ Battery efficient
- ✅ No crashes in normal use

### Feature Metrics
- ✅ Timer works accurately (25/5/15 intervals)
- ✅ Pomodoro cycles work (4 sessions = long break)
- ✅ Statistics tracking functional
- ✅ Watch app synchronized
- ✅ Notifications working
- ✅ Settings customizable

### User Experience Metrics
- ✅ Beautiful, distraction-free UI
- ✅ Intuitive navigation
- ✅ Helpful onboarding
- ✅ Clear Pomodoro education
- ✅ Engaging achievements
- ✅ Smooth animations

### Monetization Metrics
- ✅ Interstitial ads at natural break points
- ✅ Optimal ad frequency (3-4 per session)
- ✅ Ads don't interrupt focus sessions
- ✅ Good user experience with ads

---

## 🚀 Post-Launch Enhancements (Future)

1. **Advanced Features**
   - Task list integration
   - Project tracking
   - Team focus sessions
   - Social sharing
   - Export focus data

2. **Integrations**
   - Calendar integration
   - Reminders app integration
   - Shortcuts app actions
   - Widget improvements

3. **Premium Features** (Optional)
   - Ad-free option
   - Advanced analytics
   - Custom themes
   - Cloud sync
   - Multiple devices

---

## 📝 Notes

### Important Considerations
- **Data Migration**: Consider if existing users need data migration (unlikely since refactoring)
- **Backward Compatibility**: Not needed if starting fresh
- **Testing**: Test thoroughly on physical devices
- **App Store Keywords**: Focus on: pomodoro, focus timer, study timer, productivity, time management
- **Ad Placement**: Prioritize user experience over ad revenue

### Code Reuse Strategy
- **Reuse**: Timer infrastructure, analytics framework, UI components, design system
- **Refactor**: Models, views, business logic
- **Remove**: Workout-specific code, exercise-related features
- **Create**: Pomodoro-specific features, focus analytics

### File Organization
- Move workout files to focus files
- Maintain similar directory structure
- Keep analytics, UI, and system utilities organized
- Create new `Focus/` directory for focus-specific code

---

**Version**: 1.0  
**Created**: 2024  
**Status**: Ready for Implementation

