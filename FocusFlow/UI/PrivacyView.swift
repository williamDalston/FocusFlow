import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy").font(Theme.title)
                Text("We store your entries locally on your device. We do not collect personal data. Ads may use anonymous identifiers per Apple’s policies. You can remove ads with Pro in a future update.")
                Text("Data").font(Theme.headline)
                Text("Your entries are saved in your app’s sandbox. Use Export to create a copy or delete the app to remove data.")
                Text("Ads").font(Theme.headline)
                Text("We use Google Mobile Ads. If you deny tracking, ads still show but are less personalized.")
                Text("Contact").font(Theme.headline)
                Text("Support: williamdalston@gmail.com")
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}
