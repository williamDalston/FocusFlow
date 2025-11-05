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
                    
                    // Agent 8: Monitor app launch
                    PerformanceMonitor.monitorAppLaunch()
                    
                    // Agent 8: Run performance validation in debug mode
                    #if DEBUG
                    PerformanceOptimizer.deferHeavyOperations {
                        let results = PerformanceValidation.validatePerformance()
                        PerformanceValidation.logResults(results)
                    }
                    #endif
                    
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
                
                // Agent 6: Handle foreground transition
                NotificationCenter.default.post(name: NSNotification.Name("appDidBecomeActive"), object: nil)
            case .inactive: break
            case .background:
                // Agent 8: Optimize background processing
                PerformanceOptimizer.optimizeBackgroundProcessing()
                
                // Agent 6: Handle background transition
                NotificationCenter.default.post(name: NSNotification.Name("appDidEnterBackground"), object: nil)
            @unknown default: break
            }
        }
    }
}
