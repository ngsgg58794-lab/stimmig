import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: Date
    let coreName: String
    let subName: String
    let word: String
    let colorHex: String
    let note: String
    /// Reflection question the note answers (added in 1.1; missing in older entries).
    var question: String? = nil
}
