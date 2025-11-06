import SwiftUI

@main
struct FocusFlowWatchApp: App {
    @StateObject private var focusStore = WatchFocusStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(focusStore)
        }
    }
}
