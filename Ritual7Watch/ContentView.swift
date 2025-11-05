import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var workoutStore: WatchWorkoutStore
    @State private var showingWorkout = false
    @StateObject private var workoutEngine = WorkoutEngineWatch()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header with streak
                    WatchHeaderView()
                        .environmentObject(workoutStore)
                    
                    // Quick start button
                    Button(action: {
                        showingWorkout = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("Start Workout")
                                .font(.headline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    // Today's stats
                    WatchStatsView()
                        .environmentObject(workoutStore)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }
            .navigationTitle("7 Min Workout")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingWorkout) {
                NavigationStack {
                    WorkoutTimerView(engine: workoutEngine, store: workoutStore)
                }
            }
            .onAppear {
                workoutStore.load()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchWorkoutStore())
}
