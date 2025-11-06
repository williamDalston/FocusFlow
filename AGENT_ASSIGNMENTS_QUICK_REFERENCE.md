# 🎯 Agent Assignments - Quick Reference

## Agent Overview

| Agent | Task | Priority | Status |
|-------|------|----------|--------|
| **Agent 9** | App Entry Point Migration | 🔴 Critical | ⏳ Pending |
| **Agent 10** | Create FocusContentView | 🔴 Critical | ⏳ Pending |
| **Agent 11** | Update RootView Navigation | 🔴 Critical | ⏳ Pending |
| **Agent 12** | Update ThemeBackground | 🟡 High | ⏳ Pending |
| **Agent 13** | Create/Verify FocusHistoryView | 🟡 High | ⏳ Pending |
| **Agent 14** | Verify and Complete Focus Models | 🟡 High | ⏳ Pending |
| **Agent 15** | Update Analytics for Focus | 🟡 Medium | ⏳ Pending |
| **Agent 16** | Create HeroFocusCard | 🟡 High | ⏳ Pending |
| **Agent 17** | Update Apple Watch App | 🟡 Medium | ⏳ Pending |
| **Agent 18** | Update Theme Color References | 🟢 Low | ⏳ Pending |
| **Agent 19** | Remove Old Workout Views | 🟢 Low | ⏳ Pending |
| **Agent 20** | Final Testing and Cleanup | 🟢 Low | ⏳ Pending |

---

## 🔴 Phase 1: Critical Path (Start Here)

### Agent 9: App Entry Point Migration
**File:** `Ritual7/Ritual7App.swift`
- Replace `WorkoutStore` → `FocusStore`
- Replace `WorkoutPreferencesStore` → `FocusPreferencesStore`
- Update environment objects

### Agent 10: Create FocusContentView
**Create:** `Ritual7/Focus/FocusContentView.swift`
- Refactor from `WorkoutContentView.swift`
- Replace all Workout references with Focus
- Update UI for Pomodoro timer

### Agent 11: Update RootView Navigation
**File:** `Ritual7/RootView.swift`
- Replace `WorkoutContentView()` → `FocusContentView()`
- Replace `WorkoutHistoryView()` → `FocusHistoryView()`
- Update environment objects

---

## 🟡 Phase 2: Core Functionality

### Agent 12: Update ThemeBackground
**File:** `Ritual7/UI/ThemeBackground.swift`
- Use `Theme.backgroundGradient` instead of legacy colors

### Agent 13: Create/Verify FocusHistoryView
**File:** `Ritual7/Views/History/FocusHistoryView.swift`
- Create if doesn't exist
- Display focus sessions with Pomodoro info

### Agent 14: Verify and Complete Focus Models
**Files:** `Ritual7/Models/Focus*.swift`
- Verify all Focus models complete
- Remove old Workout models

### Agent 16: Create HeroFocusCard
**File:** `Ritual7/Focus/HeroFocusCard.swift`
- Create hero card for main screen
- Update for Pomodoro timer

---

## 🟢 Phase 3: Features and Polish

### Agent 15: Update Analytics for Focus
**Files:** `Ritual7/Analytics/*.swift`
- Verify FocusAnalytics complete
- Update TrendAnalyzer
- Remove WorkoutAnalytics

### Agent 17: Update Apple Watch App
**Files:** `Ritual7Watch/*`
- Update Watch app for Pomodoro timer
- Update complications

### Agent 18: Update Theme Color References
**Multiple Files**
- Gradually migrate to semantic colors
- Update timer views to use ring colors

---

## 🟢 Phase 4: Cleanup

### Agent 19: Remove Old Workout Views
**Files:** `Ritual7/Workout/*.swift`
- Delete old Workout views after migration

### Agent 20: Final Testing and Cleanup
**All Files**
- Comprehensive testing
- Code cleanup
- Performance verification

---

## 📋 Quick Start Checklist

- [ ] **Agent 9**: Update app entry point
- [ ] **Agent 10**: Create FocusContentView
- [ ] **Agent 11**: Update RootView
- [ ] **Agent 12**: Update ThemeBackground
- [ ] **Agent 13**: Create FocusHistoryView
- [ ] **Agent 14**: Verify Focus models
- [ ] **Agent 16**: Create HeroFocusCard
- [ ] **Agent 15**: Update analytics
- [ ] **Agent 17**: Update Watch app
- [ ] **Agent 18**: Update theme colors
- [ ] **Agent 19**: Remove old views
- [ ] **Agent 20**: Final testing

---

**Full Details:** See `REMAINING_WORK_AGENT_ASSIGNMENTS.md`

