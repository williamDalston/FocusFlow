# Ritual7 iOS App

A beautiful, native iOS Pomodoro timer app for focused work sessions. Built with SwiftUI for iPhone, iPad, and Apple Watch.

## 🎯 Overview

Ritual7 is a Pomodoro timer app that helps you stay focused and productive. Perfect for managing work sessions, study time, and any task that requires deep focus—just you, your phone, and 25 minutes of focused work.

## ✨ Features

### Core Features
- **Pomodoro Timer**: Classic 25-minute focus sessions with 5-minute breaks
- **Customizable Presets**: Quick Focus (15 min), Classic Pomodoro (25 min), Deep Work (45 min)
- **Beautiful UI**: Modern SwiftUI interface with glassmorphism design
- **Sound & Haptics**: Audio feedback and vibration for phase transitions
- **Progress Tracking**: Track your focus sessions, streaks, and statistics
- **Apple Watch Support**: Full Pomodoro timer companion app for Apple Watch

### Advanced Features
- **Comprehensive Analytics**: Weekly/monthly/yearly trends, progress charts, and insights
- **Achievement System**: Focus achievements with celebrations and notifications
- **Smart Notifications**: Daily reminders, streak maintenance, and productivity tips
- **Customization**: Adjustable focus/break durations, custom Pomodoro presets
- **Pomodoro Cycles**: Automatic long breaks after 4 focus sessions
- **Accessibility**: Full VoiceOver support, Dynamic Type, high contrast mode

## 📱 Platform Support

- **iPhone**: iOS 16.0+ (optimized for all iPhone models)
- **iPad**: iOS 16.0+ (with optimized layouts)
- **Apple Watch**: watchOS 10.0+ (full workout experience)
- **iOS Widgets**: Quick stats and progress tracking
- **Siri Shortcuts**: Voice-activated workout start

## 🏗️ Project Structure

```
Ritual7/
├── Ritual7.xcodeproj/               # Xcode project file
├── Ritual7/                         # Main iOS app code
│   ├── Focus/                       # Pomodoro engine, timer, and views
│   ├── Models/                      # Data models (FocusStore, FocusSession, etc.)
│   ├── UI/                          # UI components and design system
│   ├── Views/                       # Main view files
│   ├── Analytics/                   # Analytics and insights
│   ├── Motivation/                  # Achievement and motivational features
│   ├── Notifications/               # Notification management
│   ├── System/                      # System utilities
│   └── Widgets/                     # iOS Widget extension
├── Ritual7Watch/                   # Apple Watch app
└── AppStore/                        # App Store assets and documentation
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ SDK
- Apple Developer account (for device testing and App Store submission)

### Building the Project

1. **Clone or download the repository**
   ```bash
   cd "7 Minute Workout"
   ```

2. **Open in Xcode**
   ```bash
   open SevenMinuteWorkout.xcodeproj
   ```

3. **Configure Signing**
   - Select your development team in Signing & Capabilities
   - Ensure bundle identifier matches: `com.williamalston.Ritual7`

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### Testing

The project includes comprehensive test suites:
- Unit tests for core functionality
- Integration tests for HealthKit and Watch sync
- UI tests for user flows

Run tests with `Cmd+U` in Xcode.

## 📦 App Store Submission

### Pre-Submission Checklist

See `AppStore/AppStoreChecklist.md` for a complete checklist.

### Required Assets

- App icon (1024x1024 PNG)
- Screenshots for all required device sizes
- App Store description and keywords
- Privacy policy URL

### Documentation

All App Store documentation is in the `AppStore/` directory:
- `AppStoreDescription.md` - App Store listing copy
- `Keywords.txt` - Optimized keywords
- `PrivacyPolicy.md` - Privacy policy
- `ScreenshotPlan.md` - Screenshot strategy

## 🔧 Configuration

### HealthKit
HealthKit integration is optional. To enable:
1. Ensure HealthKit capability is enabled in Xcode
2. Grant HealthKit permissions when prompted
3. Workouts will automatically sync to Apple Health

### Notifications
Notifications are customizable in Settings:
- Daily workout reminders
- Streak maintenance reminders
- Achievement notifications
- Weekly progress summaries

### Analytics
Analytics are collected locally and anonymously to improve the app experience.

## 📊 Architecture

### Core Components
- **PomodoroEngine**: Manages Pomodoro timer state and timing
- **FocusStore**: Handles data persistence and statistics
- **NotificationManager**: Manages smart notifications
- **AchievementNotifier**: Tracks and notifies achievements
- **FocusPreferencesStore**: Manages user preferences and presets

### Design Patterns
- MVVM architecture
- ObservableObject for state management
- Dependency injection for testability
- Protocol-oriented design

## 🎨 Design System

The app uses a custom design system:
- **Theme Store**: Manages color themes and appearance
- **GlassCard**: Glassmorphism card component
- **Button Styles**: Consistent button styling
- **Typography**: Custom font hierarchy
- **Animations**: Smooth, purposeful animations

## 🔒 Privacy & Security

- All focus session data stored locally on device
- No personal data transmitted to servers
- Analytics are anonymized
- Full privacy policy available in `AppStore/PrivacyPolicy.md`

## 📝 Documentation

- **App Store Documentation**: `AppStore/` directory
- **Apple Watch Setup**: `APPLE_WATCH_SETUP.md`
- **Agent Plans**: `AGENT_PLAN_V2.md`, `AGENT_PLAN_FINAL_WRAP_UP.md`
- **Project Status**: `PROJECT_STATUS.md`

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
- Ensure all dependencies are resolved (Swift Package Manager)
- Clean build folder: `Product > Clean Build Folder`
- Reset package caches if needed

**Timer Not Working**
- Verify app is not in background when timer is running
- Check notification permissions for timer alerts
- Ensure device time is correctly set

**Watch Sync Issues**
- Verify Watch app is installed
- Check Watch connectivity in Settings
- Restart both iPhone and Watch if needed

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

## 📄 License

See LICENSE file for details.

## 👤 Author

**William Alston**
- Email: [Your Email]
- Website: [Your Website]

## 🙏 Acknowledgments

- Based on the Pomodoro Technique by Francesco Cirillo
- Built with SwiftUI and modern iOS development practices
- Inspired by the need for focused, productive work sessions

---

**Version**: 2.0 (Pomodoro Timer)  
**Last Updated**: December 2024  
**Minimum iOS**: 16.0  
**Bundle ID**: com.williamalston.Ritual7
