import SwiftUI

/// Legacy export button - use ExportButton from WorkoutHistoryView instead
private struct LegacyExportButton: View {
    @EnvironmentObject private var workoutStore: WorkoutStore

    var body: some View {
        Button {
            guard let data = try? JSONEncoder().encode(workoutStore.sessions) else { return }
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("workout_export.json")
            try? data.write(to: tmp, options: .atomic)
            let av = UIActivityViewController(activityItems: [tmp], applicationActivities: nil)
            UIApplication.shared.firstKeyWindow?.rootViewController?.present(av, animated: true)
            Haptics.tap()
        } label: {
            Label("Export JSON", systemImage: "square.and.arrow.up.on.square")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.white)
        .accessibilityHint("Exports your workout sessions as a JSON file")
    }
}
