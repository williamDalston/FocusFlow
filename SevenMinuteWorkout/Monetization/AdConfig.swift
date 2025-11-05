import Foundation

/// Central place for AdMob configuration.
/// Toggle `useTest` for development vs production.
enum AdConfig {
    /// Flip to `false` **before App Store submission**
    /// so your app uses real AdMob units instead of Google's test ads.
    static let useTest = false

    // MARK: - Test IDs (safe for development on device/simulator)
    private static let testBanner = "ca-app-pub-3940256099942544/2934735716"
    private static let testInterstitial = "ca-app-pub-3940256099942544/4411468910"

    // MARK: - Production IDs (your real ones from AdMob dashboard)
    private static let prodBanner = "ca-app-pub-2214618538122354/6729606327"
    private static let prodInterstitial = "ca-app-pub-2214618538122354/6623447502"

    // MARK: - Public accessors
    static var bannerUnit: String { useTest ? testBanner : prodBanner }
    static var interstitialUnit: String { useTest ? testInterstitial : prodInterstitial }
}
