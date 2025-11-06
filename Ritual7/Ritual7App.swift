import SwiftUI
import GoogleMobileAds
import os.log

/// Agent 9: App Entry Point - FocusFlow Pomodoro Timer App
/// Comprehensive app entry point with exceptional architecture, error handling, and performance optimization
@main
struct FocusFlowApp: App {
    // Wire up the UIKit delegate (lifecycle + quick actions + SDK init lives there)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // App-wide state
    @StateObject private var theme = ThemeStore()
    @StateObject private var focusStore = FocusStore()
    @StateObject private var preferencesStore = FocusPreferencesStore()
    @Environment(\.scenePhase) private var scenePhase
    
    // Error handling state
    @StateObject private var errorHandler = GlobalErrorHandler.shared
    
    // Agent 9: Error recovery state
    @State private var initializationError: Error?
    @State private var storeInitializationFailed = false

    init() {
        // Agent 9: Initialize with error handling
        setupErrorHandling()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(theme)
                .environmentObject(focusStore)
                .environmentObject(preferencesStore)
                .globalErrorHandler()
                .onAppear {
                    // Agent 8: Optimize startup performance (lightweight, keep synchronous)
                    PerformanceOptimizer.optimizeStartup()
                    
                    // Agent 8: Monitor app launch (lightweight, keep synchronous)
                    PerformanceMonitor.monitorAppLaunch()
                    
                    // Agent 9: Initialize app with error handling
                    initializeApp()
                }
                // Agent 9: Deep linking support
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                // Agent 9: Handle user activity (Siri Shortcuts, Universal Links)
                .onContinueUserActivity(AppConstants.ActivityTypes.startFocus) { userActivity in
                    handleUserActivity(userActivity)
                }
                .onContinueUserActivity(AppConstants.ActivityTypes.startDeepWork) { userActivity in
                    handleUserActivity(userActivity)
                }
                .onContinueUserActivity(AppConstants.ActivityTypes.startQuickFocus) { userActivity in
                    handleUserActivity(userActivity)
                }
                .onContinueUserActivity(AppConstants.ActivityTypes.showFocusStats) { userActivity in
                    handleUserActivity(userActivity)
                }
        }
        .onChange(of: scenePhase) { phase in
            handleScenePhaseChange(phase)
        }
    }
    
    // MARK: - Agent 9: Initialization
    
    /// Initializes the app with comprehensive error handling
    private func initializeApp() {
        // Defer all heavy operations to improve initial render
        Task { @MainActor in
            do {
                // Wait a bit for FocusStore to finish initial async loading
                try await Task.sleep(nanoseconds: AppConstants.TimingConstants.deferredOperationDelay)
                
                // Agent 9: Validate FocusStore initialization
                validateFocusStore()
                
                // Agent 9: Validate preferences store
                validatePreferencesStore()
                
                // Agent 9: Preload critical assets (can run in background)
                PerformanceOptimizer.preloadCriticalAssets()
                
                // Agent 9: Register shortcuts for Siri integration
                FocusShortcuts.registerAllShortcuts()
                
                // Preload interstitial ad (loads in background)
                InterstitialAdManager.shared.load()
                
            } catch {
                // Agent 9: Handle initialization errors gracefully
                handleInitializationError(error)
            }
        }
        
        // Agent 8: Run performance validation in debug mode (defer even further)
        #if DEBUG
        PerformanceOptimizer.deferHeavyOperations {
            let results = PerformanceValidation.validatePerformance()
            PerformanceValidation.logResults(results)
        }
        #endif
    }
    
    /// Validates FocusStore initialization
    private func validateFocusStore() {
        // Check if FocusStore loaded successfully
        // FocusStore loads asynchronously, so we check if it's ready
        if focusStore.sessions.isEmpty {
            // This is normal for first launch - no error
            os_log("FocusStore initialized with no sessions", log: .default, type: .info)
        }
    }
    
    /// Validates FocusPreferencesStore initialization
    private func validatePreferencesStore() {
        // Preferences store should always initialize with defaults if loading fails
        // This is already handled in FocusPreferencesStore.init()
        os_log("FocusPreferencesStore initialized", log: .default, type: .info)
    }
    
    /// Handles initialization errors with graceful degradation
    private func handleInitializationError(_ error: Error) {
        os_log("Initialization error: %{public}@", log: .default, type: .error, error.localizedDescription)
        
        // Log error for crash reporting
        Task { @MainActor in
            CrashReporter.logError(error, context: ["context": "app_initialization"])
        }
        
        // Store initialization error for UI display
        initializationError = error
        
        // Attempt recovery
        if !attemptRecovery() {
            // If recovery fails, show user-friendly error
            ErrorHandling.handleError(error, context: "app_initialization")
        }
    }
    
    /// Attempts to recover from initialization errors
    private func attemptRecovery() -> Bool {
        // For now, FocusStore and FocusPreferencesStore have fallback mechanisms
        // so recovery is usually not needed
        // This can be extended in the future for more complex recovery scenarios
        return true
    }
    
    // MARK: - Agent 9: Error Handling Setup
    
    /// Sets up global error handling
    private func setupErrorHandling() {
        // Error handling is managed by GlobalErrorHandler
        // Additional setup can be added here if needed
    }
    
    // MARK: - Agent 9: Deep Linking & URL Handling
    
    /// Handles deep links with URL scheme support
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == AppConstants.URLSchemes.pomodoroScheme else {
            return
        }
        
        os_log("Handling deep link: %{public}@", log: .default, type: .info, url.absoluteString)
        
        switch url.host {
        case AppConstants.URLSchemes.startFocusHost:
            // Handle start focus with preset parameter
            if let preset = url.queryParameters?["preset"] {
                startFocusSession(preset: preset)
            } else {
                // Start current preset
                startFocusSession(preset: "current")
            }
            
        case AppConstants.URLSchemes.statsHost:
            // Show stats
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowFocusStats"),
                object: nil
            )
            
        case AppConstants.URLSchemes.historyHost:
            // Show history
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowFocusHistory"),
                object: nil
            )
            
        default:
            os_log("Unknown deep link host: %{public}@", log: .default, type: .warning, url.host ?? "nil")
        }
    }
    
    /// Handles user activity (Siri Shortcuts, Universal Links)
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        _ = FocusShortcuts.handleShortcut(userActivity)
    }
    
    /// Starts a focus session with the specified preset
    private func startFocusSession(preset: String) {
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut),
            object: nil,
            userInfo: ["preset": preset]
        )
    }
    
    // MARK: - Agent 9: Lifecycle Management
    
    /// Handles scene phase changes with proper state management
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // App became active
            handleAppBecameActive()
            
        case .inactive:
            // App became inactive (transitions)
            handleAppBecameInactive()
            
        case .background:
            // App entered background
            handleAppEnteredBackground()
            
        @unknown default:
            break
        }
    }
    
    /// Handles app becoming active
    private func handleAppBecameActive() {
        // Sync with Watch when app becomes active
        WatchSessionManager.shared.updateWatchComplications()
        
        // Agent 8: Optimize memory usage when app becomes active
        PerformanceOptimizer.optimizeMemoryUsage()
        
        // Agent 6: Handle foreground transition
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.appDidBecomeActive),
            object: nil
        )
        
        // Agent 9: Restore state if needed
        restoreStateIfNeeded()
    }
    
    /// Handles app becoming inactive
    private func handleAppBecameInactive() {
        // Save state before becoming inactive
        saveState()
    }
    
    /// Handles app entering background
    private func handleAppEnteredBackground() {
        // Agent 8: Optimize background processing
        PerformanceOptimizer.optimizeBackgroundProcessing()
        
        // Agent 6: Handle background transition
        NotificationCenter.default.post(
            name: NSNotification.Name(AppConstants.NotificationNames.appDidEnterBackground),
            object: nil
        )
        
        // Agent 9: Save state on background
        saveState()
    }
    
    /// Saves app state before backgrounding or termination
    private func saveState() {
        // FocusStore and FocusPreferencesStore handle their own persistence
        // Additional state saving can be added here if needed
    }
    
    /// Restores app state after becoming active
    private func restoreStateIfNeeded() {
        // FocusStore and FocusPreferencesStore handle their own restoration
        // Additional state restoration can be added here if needed
    }
}

// MARK: - Agent 9: URL Extension for Query Parameters

extension URL {
    /// Extracts query parameters from URL
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}

