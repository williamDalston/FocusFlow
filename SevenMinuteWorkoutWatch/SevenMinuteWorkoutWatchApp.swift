import SwiftUI

@main
struct SevenMinuteWorkoutWatchApp: App {
    @StateObject private var workoutStore = WatchWorkoutStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutStore)
        }
    }
}
