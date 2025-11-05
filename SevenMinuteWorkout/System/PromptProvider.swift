import Foundation

@MainActor
final class PromptProvider: ObservableObject {
    @Published private(set) var current: String = prompts.randomElement() ?? "A tiny moment I enjoyed"

    func refresh() {
        current = Self.prompts.randomElement() ?? current
    }

    static let prompts: [String] = [
        "A person who helped me",
        "A tiny moment I enjoyed",
        "Something I learned",
        "A comfort I have",
        "Progress I made",
        "A place I felt calm",
        "Something I’m looking forward to",
        "A small win today",
        "Someone I appreciate",
        "A skill I improved"
    ]
}
