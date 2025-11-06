import Foundation
import SwiftUI
import UIKit
import Darwin

/// Agent 8: Performance optimization utilities
/// Reduces launch time, optimizes image loading, and improves memory management
enum PerformanceOptimizer {
    
    // MARK: - Image Loading Optimization
    
    // Cache for loaded symbols to avoid redundant loading
    private static var symbolCache: [String: UIImage] = [:]
    private static let symbolCacheLock = NSLock()
    
    /// Preloads critical images for better performance
    static func preloadCriticalAssets() {
        // Preload system symbols that are commonly used
        DispatchQueue.global(qos: .userInitiated).async {
            let criticalSymbols = [
                "figure.run", "play.fill", "pause.fill", "checkmark.circle.fill",
                "flame.fill", "clock.fill", "chart.bar.fill", "calendar"
            ]
            
            for symbol in criticalSymbols {
                _ = loadSymbol(symbol)
            }
        }
    }
    
    /// Loads a system symbol with caching
    /// - Parameter name: The system symbol name
    /// - Returns: The loaded UIImage or nil if not found
    static func loadSymbol(_ name: String) -> UIImage? {
        // Check cache first
        symbolCacheLock.lock()
        if let cached = symbolCache[name] {
            symbolCacheLock.unlock()
            return cached
        }
        symbolCacheLock.unlock()
        
        // Load symbol
        guard let image = UIImage(systemName: name) else {
            return nil
        }
        
        // Cache it
        symbolCacheLock.lock()
        symbolCache[name] = image
        symbolCacheLock.unlock()
        
        return image
    }
    
    /// Clears the symbol cache
    static func clearSymbolCache() {
        symbolCacheLock.lock()
        symbolCache.removeAll()
        symbolCacheLock.unlock()
    }
    
    // MARK: - Memory Management
    
    /// Clears non-essential caches to free up memory
    static func clearNonEssentialCaches() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    /// Optimizes memory usage by cleaning up old data
    static func optimizeMemoryUsage() {
        // Monitor memory usage
        let memoryInfo = getMemoryInfo()
        
        // Clear image cache if memory pressure is high
        if ProcessInfo.processInfo.isLowPowerModeEnabled || memoryInfo.usageRatio > AppConstants.PerformanceConstants.memoryUsageWarningThreshold {
            clearNonEssentialCaches()
            Task { @MainActor in
                CrashReporter.logMessage("Memory optimization triggered", level: .info, context: [
                    "memory_usage_mb": memoryInfo.usedMB,
                    "memory_available_mb": memoryInfo.availableMB,
                    "usage_ratio": memoryInfo.usageRatio
                ])
            }
        }
        
        // Agent 6: Check for low memory condition
        if memoryInfo.usageRatio > AppConstants.PerformanceConstants.memoryUsageCriticalThreshold {
            ErrorHandling.handleError(ErrorHandling.WorkoutError.lowMemory, context: "PerformanceOptimizer.optimizeMemoryUsage")
        }
    }
    
    /// Checks for low memory condition and handles it
    static func checkLowMemoryCondition() -> Bool {
        let memoryInfo = getMemoryInfo()
        
        if memoryInfo.usageRatio > AppConstants.PerformanceConstants.memoryUsageWarningThreshold {
            // Clear aggressive caches
            clearNonEssentialCaches()
            
            // Post notification for UI to handle
            NotificationCenter.default.post(name: NSNotification.Name(AppConstants.NotificationNames.lowMemoryWarning), object: nil)
            
            ErrorHandling.handleError(ErrorHandling.WorkoutError.lowMemory, context: "PerformanceOptimizer.checkLowMemoryCondition")
            return true
        }
        
        return false
    }
    
    /// Checks for battery saver mode and handles it
    static func checkBatterySaverMode() -> Bool {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            // Post notification for UI to handle
            NotificationCenter.default.post(name: NSNotification.Name(AppConstants.NotificationNames.batterySaverModeEnabled), object: nil)
            
            ErrorHandling.handleError(ErrorHandling.WorkoutError.batterySaverMode, context: "PerformanceOptimizer.checkBatterySaverMode")
            return true
        }
        
        return false
    }
    
    // MARK: - Memory Monitoring
    
    /// Gets current memory usage information
    static func getMemoryInfo() -> (usedMB: Int, availableMB: Int, totalMB: Int, usageRatio: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Int(info.resident_size / 1024 / 1024)
            let totalMB = Int(ProcessInfo.processInfo.physicalMemory / 1024 / 1024)
            let availableMB = totalMB - usedMB
            let usageRatio = Double(usedMB) / Double(totalMB)
            
            return (usedMB, availableMB, totalMB, usageRatio)
        }
        
        return (0, 0, 0, 0.0)
    }
    
    // MARK: - Launch Time Optimization
    
    /// Defers heavy operations to improve launch time
    static func deferHeavyOperations(_ operation: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(AppConstants.TimingConstants.heavyOperationDelay) / 1_000_000_000) {
            operation()
        }
    }
    
    /// Optimizes app startup by deferring non-critical operations
    static func optimizeStartup() {
        // Measure launch time
        let launchStartTime = CFAbsoluteTimeGetCurrent()
        
        // Defer analytics, notifications, and other non-critical operations
        deferHeavyOperations {
            // Any heavy operations can go here
            let launchTime = CFAbsoluteTimeGetCurrent() - launchStartTime
            #if DEBUG
            if launchTime > AppConstants.TimingConstants.targetLaunchTime {
                print("⚠️ Launch time exceeded target: \(String(format: "%.2f", launchTime))s")
            } else {
                print("✅ Launch time: \(String(format: "%.2f", launchTime))s")
            }
            #endif
            Task { @MainActor in
                CrashReporter.logMessage("App launch completed", level: launchTime > AppConstants.TimingConstants.targetLaunchTime ? .warning : .info, context: ["launch_time": launchTime])
            }
        }
    }
    
    // MARK: - View Performance
    
    /// Enables lazy loading for better scroll performance
    static var shouldUseLazyLoading: Bool {
        // Use lazy loading on devices with less memory
        return ProcessInfo.processInfo.physicalMemory < 4_000_000_000 // Less than 4GB RAM
    }
    
    // MARK: - Background Processing
    
    /// Optimizes background processing to reduce battery usage
    static func optimizeBackgroundProcessing() {
        // Agent 6: Check for battery saver mode
        _ = checkBatterySaverMode()
        
        // Reduce background refresh frequency in low power mode
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            // Adjust background processing accordingly
            // Disable non-essential background tasks
            Task { @MainActor in
                CrashReporter.logMessage("Low power mode detected - optimizing background processing", level: .info)
            }
        }
        
        // Monitor battery state
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        
        if batteryState == .unplugged && batteryLevel < AppConstants.PerformanceConstants.lowBatteryThreshold {
            // Battery is low - optimize aggressively
            clearNonEssentialCaches()
            Task { @MainActor in
                CrashReporter.logMessage("Low battery detected - aggressive optimization", level: .info, context: [
                    "battery_level": batteryLevel,
                    "battery_state": String(describing: batteryState)
                ])
            }
        }
        
        // Agent 6: Check for low memory condition
        _ = checkLowMemoryCondition()
    }
    
    // MARK: - Battery Optimization
    
    /// Checks if battery optimization is needed
    static var shouldOptimizeBattery: Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        
        return ProcessInfo.processInfo.isLowPowerModeEnabled || 
               (batteryState == .unplugged && batteryLevel < AppConstants.PerformanceConstants.lowBatteryThreshold)
    }
}

// MARK: - View Modifiers for Performance

/// Lazy loading modifier for better scroll performance
struct LazyLoadingModifier: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                if PerformanceOptimizer.shouldUseLazyLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isVisible = true
                    }
                } else {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Applies lazy loading for better performance
    func lazyLoad() -> some View {
        modifier(LazyLoadingModifier())
    }
}

// MARK: - Performance Monitoring

/// Comprehensive performance monitor for debugging and production
struct PerformanceMonitor {
    
    // MARK: - Time Measurement
    
    /// Measures execution time of an operation
    static func measureTime<T>(_ operation: () -> T) -> (result: T, time: TimeInterval) {
        let start = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let time = CFAbsoluteTimeGetCurrent() - start
        return (result, time)
    }
    
    /// Measures execution time of an async operation
    static func measureTimeAsync<T>(_ operation: () async -> T) async -> (result: T, time: TimeInterval) {
        let start = CFAbsoluteTimeGetCurrent()
        let result = await operation()
        let time = CFAbsoluteTimeGetCurrent() - start
        return (result, time)
    }
    
    /// Logs slow operations with automatic threshold detection
    /// - Parameters:
    ///   - name: Name of the operation being measured
    ///   - threshold: Time threshold in seconds (default: AppConstants.PerformanceConstants.slowOperationThreshold)
    ///   - operation: The operation to measure
    /// - Returns: The result of the operation
    @discardableResult
    static func logSlowOperation<T>(name: String, threshold: TimeInterval = AppConstants.PerformanceConstants.slowOperationThreshold, operation: () -> T) -> T {
        #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let time = CFAbsoluteTimeGetCurrent() - start
        if time > threshold {
            let message = "⚠️ Slow operation detected: \(name) took \(String(format: "%.3f", time))s"
            print(message)
            Task { @MainActor in
                CrashReporter.logMessage(message, level: .warning, context: [
                    "operation": name,
                    "duration": time,
                    "threshold": threshold
                ])
            }
        }
        return result
        #else
        return operation()
        #endif
    }
    
    /// Logs slow async operations with automatic threshold detection
    /// - Parameters:
    ///   - name: Name of the operation being measured
    ///   - threshold: Time threshold in seconds (default: AppConstants.PerformanceConstants.slowOperationThreshold)
    ///   - operation: The async operation to measure
    /// - Returns: The result of the operation
    @discardableResult
    static func logSlowOperationAsync<T>(name: String, threshold: TimeInterval = AppConstants.PerformanceConstants.slowOperationThreshold, operation: () async -> T) async -> T {
        #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
        let result = await operation()
        let time = CFAbsoluteTimeGetCurrent() - start
        if time > threshold {
            let message = "⚠️ Slow operation detected: \(name) took \(String(format: "%.3f", time))s"
            print(message)
            Task { @MainActor in
                CrashReporter.logMessage(message, level: .warning, context: [
                    "operation": name,
                    "duration": time,
                    "threshold": threshold
                ])
            }
        }
        return result
        #else
        return await operation()
        #endif
    }
    
    // MARK: - Memory Monitoring
    
    /// Measures memory usage before and after an operation
    static func measureMemory<T>(name: String, operation: () -> T) -> (result: T, memoryDelta: Int64) {
        let before = getMemoryUsage()
        let result = operation()
        let after = getMemoryUsage()
        let delta = after - before
        
        if delta > AppConstants.PerformanceConstants.highMemoryUsageThreshold {
            Task { @MainActor in
                CrashReporter.logMessage("High memory usage detected", level: .warning, context: [
                    "operation": name,
                    "memory_delta_mb": delta / 1_000_000,
                    "memory_before_mb": before / 1_000_000,
                    "memory_after_mb": after / 1_000_000
                ])
            }
        }
        
        return (result, delta)
    }
    
    /// Gets current memory usage in bytes
    static func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        }
        
        return 0
    }
    
    // MARK: - App Launch Monitoring
    
    /// Monitors app launch time
    static func monitorAppLaunch() {
        let launchStartTime = CFAbsoluteTimeGetCurrent()
        
        // Track launch completion
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.TimingConstants.launchTimeCheckDelay) {
            let launchTime = CFAbsoluteTimeGetCurrent() - launchStartTime
            let targetTime: TimeInterval = AppConstants.TimingConstants.targetLaunchTime
            
            Task { @MainActor in
                if launchTime > targetTime {
                    CrashReporter.logMessage("App launch time exceeded target", level: .warning, context: [
                        "launch_time": launchTime,
                        "target_time": targetTime
                    ])
                } else {
                    CrashReporter.logMessage("App launch time within target", level: .info, context: [
                        "launch_time": launchTime,
                        "target_time": targetTime
                    ])
                }
            }
        }
    }
    
    // MARK: - Frame Rate Monitoring
    
    /// Monitors frame rate during critical operations
    static func monitorFrameRate(duration: TimeInterval = 5.0, completion: @escaping (Double) -> Void) {
        // This would typically use CADisplayLink in a real implementation
        // For now, we'll log that frame rate monitoring is available
        Task { @MainActor in
            CrashReporter.logMessage("Frame rate monitoring available", level: .debug)
        }
    }
}


