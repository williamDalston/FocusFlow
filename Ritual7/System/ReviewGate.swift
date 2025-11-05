import StoreKit
import UIKit

enum ReviewGate {
    private static let milestones: Set<Int> = [7, 30, 90]

    /// Lightly ask for a review at meaningful milestones.
    @MainActor
    static func considerPrompt(totalSaves: Int) {
        // Prompt only at real moments (feels earned)
        guard milestones.contains(totalSaves) else { return }

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        if #available(iOS 18.0, *) {
            // New API on iOS 18
            AppStore.requestReview(in: scene)
        } else {
            // Older iOS
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
