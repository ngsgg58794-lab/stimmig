import SwiftUI

/// Data for one month's mood mosaic.
struct MonthRecap {
    struct CoreShare: Identifiable {
        let name: String
        let hex: String
        let count: Int
        var id: String { name }
    }

    let month: Date
    let days: [Date]
    /// Leading empty cells so the first day lands on its weekday (Monday first).
    let leadingBlanks: Int
    let colorByDay: [Date: String]
    let topCores: [CoreShare]
    let entryCount: Int

    init(month: Date, entries: [JournalEntry], calendar: Calendar) {
        let start = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<31
        self.month = start
        days = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
        leadingBlanks = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7

        let inMonth = entries.filter { calendar.isDate($0.timestamp, equalTo: start, toGranularity: .month) }
        entryCount = inMonth.count
        // Each day takes the colour of the feeling that came up most often that day.
        colorByDay = Dictionary(grouping: inMonth) { calendar.startOfDay(for: $0.timestamp) }
            .compactMapValues { dayEntries in
                Dictionary(grouping: dayEntries, by: \.colorHex)
                    .max { $0.value.count < $1.value.count }?.key
            }
        topCores = EmotionWheelData.core
            .map { core in
                CoreShare(name: core.name, hex: core.hex, count: inMonth.filter { $0.coreName == core.name }.count)
            }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }

    var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: month)
    }
}

/// The shareable mosaic image (rendered at 360×450 pt → 1080×1350 px, Instagram portrait).
struct MonthRecapView: View {
    let recap: MonthRecap

    private let background = Color(hex: "#FBFAF7")
    private let ink = Color(hex: "#16130F")
    private let muted = Color(hex: "#7A736B")
    private let empty = Color(hex: "#ECE7DF")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                BrandMark(size: 22)
                Text("stimmig")
                    .font(.display(17))
                    .foregroundStyle(ink)
                Spacer()
                Text("\(recap.entryCount) Gefühle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(muted)
            }

            Text("Mein \(recap.title)")
                .font(.display(28))
                .tracking(-0.8)
                .foregroundStyle(ink)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(0..<recap.leadingBlanks, id: \.self) { _ in
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
                ForEach(recap.days, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(recap.colorByDay[day].map { Color(hex: $0) } ?? empty)
                        .aspectRatio(1, contentMode: .fit)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                ForEach(recap.topCores) { item in
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: item.hex)).frame(width: 10, height: 10)
                        Text(item.name)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(ink)
                    }
                }
            }
        }
        .padding(22)
        .frame(width: 360, height: 450)
        .background(background)
    }
}
