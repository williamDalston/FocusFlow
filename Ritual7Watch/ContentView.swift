import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var focusStore: WatchFocusStore
    @State private var showingFocus = false
    @StateObject private var pomodoroEngine = PomodoroEngineWatch()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header with streak
                    WatchFocusHeaderView()
                        .environmentObject(focusStore)
                    
                    // Quick start button
                    Button(action: {
                        showingFocus = true
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title3)
                            Text("Start Focus")
                                .font(.headline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    // Today's stats
                    WatchFocusStatsView()
                        .environmentObject(focusStore)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }
            .navigationTitle("Pomodoro")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFocus) {
                NavigationStack {
                    FocusTimerView(engine: pomodoroEngine, store: focusStore)
                }
            }
            .onAppear {
                focusStore.load()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchFocusStore())
}
