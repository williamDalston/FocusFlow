import SwiftUI

@main
struct Ritual7WatchApp: App {
    @StateObject private var focusStore = WatchFocusStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(focusStore)
        }
    }
}
