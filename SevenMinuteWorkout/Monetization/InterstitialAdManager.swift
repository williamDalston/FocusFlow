import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

/// Shared interstitial ad manager for the entire app
@MainActor
final class InterstitialAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = InterstitialAdManager()
    
    @Published private(set) var isReady = false
    @Published private(set) var shownThisSession = 0

    private var interstitial: InterstitialAd?
    private let unitID: String

    // Tuning
    var sessionCap = 3                 // max per app launch
    var minimumSecondsBetween = 90.0   // cooldown

    private var lastShown: Date?

    private override init() {
        self.unitID = AdConfig.interstitialUnit
        super.init()
        // Preload ad on initialization
        load()
    }

    func load() {
        Task { [weak self] in
            guard let self else { return }
            do {
                // FIXED: use `with:` label
                let ad = try await InterstitialAd.load(with: unitID, request: Request())
                ad.fullScreenContentDelegate = self
                self.interstitial = ad
                self.isReady = true
            } catch {
                self.interstitial = nil
                self.isReady = false
                print("Interstitial load failed:", error.localizedDescription)
            }
        }
    }

    private func isEligibleToShow() -> Bool {
        guard shownThisSession < sessionCap else { return false }
        if let last = lastShown, Date().timeIntervalSince(last) < minimumSecondsBetween { return false }
        return true
    }

    func present(from vc: UIViewController?) {
        guard isEligibleToShow() else { return }
        guard let ad = interstitial else { load(); return }

        isReady = false
        let presenter = vc ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController

        ad.present(from: presenter)
        shownThisSession += 1
        lastShown = Date()
    }

    // MARK: - FullScreenContentDelegate
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitial = nil
        isReady = false
        load()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitial = nil
        isReady = false
        load()
    }
}
