# 🖱️ Simulator Testing Guide - Mouse & Keyboard Support

## Overview

This app is fully optimized for testing in the iOS Simulator using both mouse/trackpad and keyboard controls.

## ✅ Mouse & Trackpad Support

### Automatic Support
iOS Simulator automatically converts mouse clicks to touch events, so all interactive elements work seamlessly:

- **Buttons**: All buttons respond to mouse clicks
- **Tap Gestures**: All `.onTapGesture` handlers work with mouse clicks
- **Lists & ScrollViews**: Fully scrollable with mouse wheel or trackpad
- **Navigation**: All navigation links work with mouse clicks
- **Sheets & Modals**: All modal presentations work with mouse clicks

### Hit Testing
All interactive elements have proper hit testing areas:

- ✅ All buttons use `.contentShape(Rectangle())` for proper click areas
- ✅ All tap gestures use `.contentShape(Rectangle())` for full-area clicking
- ✅ Minimum touch targets are 44x44pt (Apple's recommended minimum)
- ✅ All interactive elements are properly sized for easy clicking

## ⌨️ Keyboard Shortcuts

### Workout Controls
- **Spacebar**: Pause/Resume workout (when workout is active)
- **Enter**: Start workout (from main screen)

### Navigation
- **Tab**: Navigate between interactive elements
- **Enter/Space**: Activate focused button
- **Escape**: Dismiss modal/sheet (when available)

### iPad Keyboard Support
Full keyboard navigation is available on iPad simulator:
- All buttons are keyboard accessible
- Tab navigation works throughout the app
- Enter/Space activates buttons

## 🎯 Gesture Support

### Swipe Gestures
The app includes swipe gestures for workout control:
- **Swipe Right**: Pause/Resume workout
- **Swipe Left**: Skip rest period

**Note**: Swipe gestures require drag movements and work best with trackpad/mouse drag. For mouse-only testing, use the button controls instead.

### Visual Effects
- **Tilt Effect**: Visual effect that responds to drag gestures
  - Does NOT interfere with mouse clicks
  - Works with mouse drag for visual feedback
  - All tap gestures work independently

## 🧪 Testing Tips

### Mouse Testing
1. **Click any button** - All buttons respond to mouse clicks
2. **Click on list items** - All tap gestures work with mouse
3. **Scroll with mouse wheel** - All ScrollViews support mouse wheel scrolling
4. **Click navigation links** - All NavigationLink items work with mouse

### Keyboard Testing (iPad)
1. **Tab through elements** - Navigate with Tab key
2. **Press Space/Enter** - Activate buttons
3. **Press Space during workout** - Pause/Resume workout
4. **Press Enter on main screen** - Start workout

### Trackpad Testing
1. **Two-finger scroll** - Scroll through lists
2. **Click to tap** - All tap gestures work
3. **Drag for swipe** - Swipe gestures work with trackpad drag
4. **Pinch to zoom** - Standard iOS gestures work

## 📱 Simulator-Specific Features

### Visual Feedback
- All buttons provide visual feedback on mouse hover (iOS 15+)
- Press states are clearly visible
- Scale animations show button press feedback

### Accessibility
- All interactive elements have proper accessibility labels
- VoiceOver navigation works with keyboard
- All buttons have helpful hints for keyboard users

## ✅ Verified Working

- ✅ Mouse clicks on all buttons
- ✅ Mouse clicks on all tap gestures
- ✅ Mouse wheel scrolling
- ✅ Trackpad gestures
- ✅ Keyboard shortcuts (iPad)
- ✅ Tab navigation
- ✅ Spacebar pause/resume
- ✅ Enter key to start workout
- ✅ All navigation flows
- ✅ All sheet presentations
- ✅ All modal dismissals

## 🎯 Best Practices

1. **Use mouse for primary testing** - Most efficient for UI navigation
2. **Use keyboard shortcuts for workflow testing** - Faster for repeated actions
3. **Use trackpad for gesture testing** - Best for swipe gestures
4. **Test on both iPhone and iPad simulators** - Different keyboard support levels

## 📝 Notes

- Mouse clicks work automatically - no special configuration needed
- Keyboard shortcuts work best on iPad simulator
- All gestures work with both touch and mouse/trackpad
- Button feedback is optimized for both touch and mouse interactions

