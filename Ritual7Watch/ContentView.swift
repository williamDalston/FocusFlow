import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var focusStore: WatchFocusStore
    @State private var showingFocus = false
    @StateObject private var pomodoroEngine = PomodoroEngineWatch()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.comfortable) {
                    // Header with streak
                    WatchFocusHeaderView()
                        .environmentObject(focusStore)
                    
                    // Quick start button
                    Button(action: {
                        showingFocus = true
                    }) {
                        HStack(spacing: DesignSystem.Spacing.iconSpacing) {
                            Image(systemName: "brain.head.profile")
                                .font(.title3)
                            Text("Start Focus")
                                .font(.headline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.comfortable)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                                .fill(Color.blue)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    // Today's stats
                    WatchFocusStatsView()
                        .environmentObject(focusStore)
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.top, DesignSystem.Spacing.tight)
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
