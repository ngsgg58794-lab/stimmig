import Foundation

enum JournalStats {
    /// Consecutive days with at least one entry. Counts from today, or from yesterday
    /// if there is no entry yet today, so the streak doesn't reset before the day is over.
    static func streak(_ entries: [JournalEntry], now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.timestamp) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    static func latest(_ entries: [JournalEntry]) -> JournalEntry? {
        entries.max { $0.timestamp < $1.timestamp }
    }

    static func streakLabel(_ days: Int) -> String {
        days == 1 ? "1 Tag in Folge" : "\(days) Tage in Folge"
    }
}
