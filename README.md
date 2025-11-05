# 7-Minute Workout iOS App

A beautiful, native iOS workout app featuring the scientifically-backed 7-minute high-intensity interval training (HIIT) routine. Built with SwiftUI for iPhone, iPad, and Apple Watch.

## 🎯 Overview

7-Minute Workout brings you the scientifically-backed high-intensity interval training routine that delivers maximum results in minimal time. Perfect for busy schedules, no gym required, and no equipment needed—just you, your phone, and 7 minutes of commitment.

## ✨ Features

### Core Features
- **12 High-Intensity Exercises**: Complete the full 7-minute workout routine
- **Beautiful UI**: Modern SwiftUI interface with circular progress indicators
- **Sound & Haptics**: Audio feedback and vibration for workout transitions
- **Progress Tracking**: Track your workout history, streaks, and statistics
- **Apple Watch Support**: Full workout companion app for Apple Watch
- **HealthKit Integration**: Seamless sync with Apple Health and Activity apps

### Advanced Features
- **Comprehensive Analytics**: Weekly/monthly/yearly trends, progress charts, and insights
- **Achievement System**: 15+ achievements with celebrations and notifications
- **Smart Notifications**: Daily reminders, streak maintenance, and motivational messages
- **Customization**: Adjustable exercise/rest durations, custom workouts, presets
- **Exercise Guide**: Detailed form instructions, modifications, and safety tips
- **Accessibility**: Full VoiceOver support, Dynamic Type, high contrast mode

## 📱 Platform Support

- **iPhone**: iOS 16.0+ (optimized for all iPhone models)
- **iPad**: iOS 16.0+ (with optimized layouts)
- **Apple Watch**: watchOS 10.0+ (full workout experience)
- **iOS Widgets**: Quick stats and progress tracking
- **Siri Shortcuts**: Voice-activated workout start

## 🏗️ Project Structure

```
SevenMinuteWorkout/
├── SevenMinuteWorkout.xcodeproj/    # Xcode project file
├── SevenMinuteWorkout/              # Main iOS app code
│   ├── Workout/                     # Workout engine, timer, and views
│   ├── Models/                      # Data models (WorkoutStore, Exercise, etc.)
│   ├── UI/                          # UI components and design system
│   ├── Views/                       # Main view files
│   ├── Analytics/                   # Analytics and insights
│   ├── Health/                      # HealthKit integration
│   ├── Motivation/                  # Achievement and motivational features
│   ├── Notifications/               # Notification management
│   ├── System/                      # System utilities
│   └── Widgets/                     # iOS Widget extension
├── SevenMinuteWorkoutWatch/         # Apple Watch app
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
   - Ensure bundle identifier matches: `williamalston.SevenMinuteWorkout`

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
- **WorkoutEngine**: Manages workout state and timing
- **WorkoutStore**: Handles data persistence and statistics
- **NotificationManager**: Manages smart notifications
- **AchievementNotifier**: Tracks and notifies achievements
- **HealthKitManager**: Handles HealthKit integration

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

- All workout data stored locally on device
- HealthKit integration is optional and privacy-respecting
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

**HealthKit Not Working**
- Verify HealthKit capability is enabled
- Check permissions in iOS Settings > Privacy & Security > Health
- Ensure device supports HealthKit

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

- Based on the 7-minute workout research from the American College of Sports Medicine
- Built with SwiftUI and modern iOS development practices
- Inspired by the need for quick, effective home workouts

---

**Version**: 1.3  
**Last Updated**: November 2024  
**Minimum iOS**: 16.0  
**Bundle ID**: williamalston.SevenMinuteWorkout
