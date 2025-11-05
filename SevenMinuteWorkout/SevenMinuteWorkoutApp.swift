import SwiftUI
import GoogleMobileAds

@main
struct SevenMinuteWorkoutApp: App {
    // Wire up the UIKit delegate (lifecycle + quick actions + SDK init lives there)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // App-wide state
    @StateObject private var theme = ThemeStore()
    @StateObject private var workoutStore = WorkoutStore()
    @StateObject private var preferencesStore = WorkoutPreferencesStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(theme)
                .environmentObject(workoutStore)
                .environmentObject(preferencesStore)
                .onAppear {
                    // Agent 16: Configure preferences store with workout store
                    preferencesStore.configure(with: workoutStore)
                    // Agent 8: Optimize startup performance
                    PerformanceOptimizer.optimizeStartup()
                    PerformanceOptimizer.preloadCriticalAssets()
                    
                    // Register shortcuts for Siri integration
                    WorkoutShortcuts.registerWorkoutShortcut()
                }
        }
        .onChange(of: scenePhase) { phase in
            // Handle Watch connectivity when app becomes active
            switch phase {
            case .active:
                // Sync with Watch when app becomes active
                // WatchSessionManager.shared.sendEntriesToWatch()
                WatchSessionManager.shared.updateWatchComplications()
                
                // Agent 8: Optimize memory usage when app becomes active
                PerformanceOptimizer.optimizeMemoryUsage()
            case .inactive: break
            case .background:
                // Agent 8: Optimize background processing
                PerformanceOptimizer.optimizeBackgroundProcessing()
            @unknown default: break
            }
        }
    }
}
