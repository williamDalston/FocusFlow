# App Store Connect Response - Background Audio Mode

**Submission ID:** 8ac244ef-9ff3-4081-adac-ed6f9cafcca8  
**Review Date:** November 11, 2025  
**Version:** 1.0

---

## Response to App Review Team

Hi there,

Thanks for catching that! You're absolutely right - I've removed the "audio" setting from the UIBackgroundModes key in Info.plist.

The app is a Pomodoro timer, so it doesn't actually need background audio mode. It only plays short sound effects (like start/rest/complete tones) and optional ambient sounds when you're using the app in the foreground. The timer itself continues running in the background just fine without the audio background mode - it's not like a music player that needs to keep playing audio when you switch apps.

I've tested the updated build and everything still works perfectly:
- All sound effects play correctly when the app is open
- The timer continues running in the background as expected
- No functionality was lost by removing the audio background mode

The new build with the corrected Info.plist is ready for review. Thanks for the feedback!

Best,  
William Alston

---

## Technical Notes (for reference)

**What changed:** Removed the entire `UIBackgroundModes` array with the "audio" key from `FocusFlow/Info.plist`.

The audio background mode is meant for apps that play continuous audio in the background (like music players or podcasts), but this Pomodoro timer only needs short sound effects when the app is active. The timer continues working in the background through standard iOS background execution, so no audio background mode is needed.

