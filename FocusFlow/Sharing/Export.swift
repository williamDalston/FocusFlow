import SwiftUI

/// Agent 25: Updated for Focus - Export functionality for focus sessions
/// Legacy export button - use ExportButton from FocusHistoryView instead
private struct LegacyExportButton: View {
    @EnvironmentObject private var focusStore: FocusStore

    var body: some View {
        Button {
            guard let data = try? JSONEncoder().encode(focusStore.sessions) else { return }
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("focus_export.json")
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
        .accessibilityHint("Exports your focus sessions as a JSON file")
    }
}

// MARK: - Export Functions

/// Agent 25: Export focus sessions to JSON format
func exportFocusSessionsToJSON(sessions: [FocusSession]) throws -> Data {
    return try JSONEncoder().encode(sessions)
}

/// Agent 25: Export focus sessions to CSV format
func exportFocusSessionsToCSV(sessions: [FocusSession]) -> String {
    var csv = "Date,Duration (minutes),Phase Type,Completed,Notes\n"
    
    for session in sessions {
        let dateString = session.date.ISO8601Format()
        let durationMinutes = Int(session.duration) / 60
        let phaseType = session.phaseType.rawValue
        let completed = session.completed ? "Yes" : "No"
        let notes = session.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
        
        csv += "\"\(dateString)\",\(durationMinutes),\"\(phaseType)\",\"\(completed)\",\"\(notes)\"\n"
    }
    
    return csv
}
