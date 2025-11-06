import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit
import os.log

/// Shared interstitial ad manager for the entire app
/// Optimized for maximum revenue with minimal user interruption
@MainActor
final class InterstitialAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = InterstitialAdManager()
    
    @Published private(set) var isReady = false
    @Published private(set) var shownThisSession = 0

    private var interstitial: InterstitialAd?
    private let unitID: String

    // Tuning - Optimized for revenue without being annoying
    // For Pomodoro app: Users may have 4-8 focus sessions per day, so 3-4 ads per session is reasonable
    var sessionCap = 4                 // max per app launch (Pomodoro: more sessions per day than workouts)
    var minimumSecondsBetween = 90.0   // cooldown (prevents ad fatigue)

    private var lastShown: Date?
    private var loadAttempts = 0
    private let maxLoadAttempts = 3
    private var retryDelay: TimeInterval = 2.0

    private override init() {
        self.unitID = AdConfig.interstitialUnit
        super.init()
        // Preload ad on initialization
        load()
    }

    /// Load interstitial ad with retry logic for maximum fill rate
    func load() {
        // Prevent excessive load attempts
        guard loadAttempts < maxLoadAttempts else {
            // Reset after delay to allow network recovery
            Task {
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                loadAttempts = 0
            }
            return
        }
        
        loadAttempts += 1
        Task { [weak self] in
            guard let self else { return }
            do {
                let ad = try await InterstitialAd.load(with: unitID, request: Request())
                ad.fullScreenContentDelegate = self
                self.interstitial = ad
                self.isReady = true
                self.loadAttempts = 0 // Reset on success
            } catch {
                self.interstitial = nil
                self.isReady = false
                os_log("Interstitial load failed (attempt %d): %{public}@", log: .default, type: .error, self.loadAttempts, error.localizedDescription)
                
                // Retry with exponential backoff (schedule retry, don't call recursively)
                if self.loadAttempts < self.maxLoadAttempts {
                    let delay = self.retryDelay * Double(self.loadAttempts)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    // Schedule retry by calling load again (it will check loadAttempts)
                    await MainActor.run {
                        self.load()
                    }
                } else {
                    os_log("Interstitial ad load failed after %d attempts, will retry later", log: .default, type: .info, self.maxLoadAttempts)
                }
            }
        }
    }
    
    /// Preload next ad proactively to ensure we always have one ready
    private func preloadNextAd() {
        // This will be called after ad is shown to preload next one
        // We don't preload if we already have one ready (to save bandwidth)
        guard !isReady else { return }
        
        // Small delay to avoid immediate load after showing ad
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            self?.load()
        }
    }

    /// Check if ad is eligible to show (respects caps and cooldowns)
    private func isEligibleToShow() -> Bool {
        // Check session cap
        guard shownThisSession < sessionCap else { return false }
        
        // Check cooldown period
        if let last = lastShown, Date().timeIntervalSince(last) < minimumSecondsBetween {
            return false
        }
        
        // Check if ad is ready
        guard isReady, interstitial != nil else { return false }
        
        return true
    }

    /// Present interstitial ad if eligible
    /// - Parameter vc: Optional view controller to present from (nil uses root VC)
    func present(from vc: UIViewController?) {
        // Only show if eligible (respects caps and cooldowns)
        guard isEligibleToShow() else { 
            // If not eligible but we don't have an ad, try to load one for next time
            if !isReady {
                load()
            }
            return 
        }
        
        guard let ad = interstitial else { 
            // Try to load for next time
            load()
            return 
        }

        // Mark as not ready before presenting (ad will be consumed)
        isReady = false
        
        // Get root view controller safely
        let presenter: UIViewController?
        if let vc = vc {
            presenter = vc
        } else {
            presenter = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.rootViewController
        }
        
        guard let presenter = presenter else {
            os_log("Failed to get root view controller for ad presentation", log: .default, type: .error)
            // Try to load next ad
            load()
            return
        }

        // Present the ad
        ad.present(from: presenter)
        shownThisSession += 1
        lastShown = Date()
        
        os_log("Interstitial ad presented successfully (session count: %d)", log: .default, type: .info, shownThisSession)
        
        // Preload next ad immediately after showing (for maximum fill rate)
        // This ensures we always have an ad ready for the next opportunity
        preloadNextAd()
    }
    
    /// Reset session counters (useful for testing or app lifecycle management)
    func resetSession() {
        shownThisSession = 0
        lastShown = nil
    }

    // MARK: - FullScreenContentDelegate
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        os_log("Interstitial ad failed to present: %{public}@", log: .default, type: .error, error.localizedDescription)
        interstitial = nil
        isReady = false
        // Immediately load next ad to maintain fill rate
        load()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitial = nil
        isReady = false
        // Immediately load next ad after dismissal (critical for maximum revenue)
        // This ensures we always have an ad ready for the next natural break point
        load()
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        // Ad was successfully shown - track if needed
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        // User clicked ad - track if needed
    }
}
