import AppTrackingTransparency
import AdSupport

enum AppTrackingManager {
    private static let askedKey = "att.hasAskedOnce"

    static func requestIfAppropriate() {
        // Only ask once per install.
        guard !UserDefaults.standard.bool(forKey: askedKey) else { return }

        // Apple recommends requesting when there’s context. Do it on main queue.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { status in
                UserDefaults.standard.set(true, forKey: askedKey)
                // Optional: log status
                print("ATT status:", status.rawValue)
            }
        }
    }
}
