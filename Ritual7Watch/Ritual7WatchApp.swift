import SwiftUI

@main
struct Ritual7WatchApp: App {
    @StateObject private var workoutStore = WatchWorkoutStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutStore)
        }
    }
}
