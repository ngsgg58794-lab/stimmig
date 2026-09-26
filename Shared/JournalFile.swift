import Foundation

enum AppGroup {
    static let id = "group.com.pinksharkdesign.stimmig"
}

/// The journal as a single JSON file. It lives in the App Group container so the
/// widget can read it; falls back to the app's Documents directory if the group is unavailable.
enum JournalFile {
    private static let fileName = "stimmig_journal.json"

    static var url: URL {
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.id) {
            return container.appendingPathComponent(fileName)
        }
        return legacyURL
    }

    /// Location used by version 1.0 (app-private Documents directory).
    private static var legacyURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    /// Moves a journal written by version 1.0 into the shared container, once.
    static func migrateIfNeeded() {
        let fm = FileManager.default
        let target = url
        guard target != legacyURL,
              fm.fileExists(atPath: legacyURL.path),
              !fm.fileExists(atPath: target.path) else { return }
        try? fm.moveItem(at: legacyURL, to: target)
    }

    static func load() -> [JournalEntry] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([JournalEntry].self, from: data)) ?? []
    }

    static func save(_ entries: [JournalEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
