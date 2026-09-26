import Foundation
import WidgetKit

/// Local, login-free persistence for journal entries — a JSON file shared with the widget.
@MainActor
final class JournalStore: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []

    init() {
        JournalFile.migrateIfNeeded()
        entries = JournalFile.load().sorted { $0.timestamp > $1.timestamp }
    }

    func add(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func delete(id: String) {
        entries.removeAll { $0.id == id }
        save()
    }

    private func save() {
        JournalFile.save(entries)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
