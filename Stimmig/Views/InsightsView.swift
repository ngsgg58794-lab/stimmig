import SwiftUI
import Charts

struct InsightsView: View {
    @ObservedObject var store: JournalStore
    let onNew: () -> Void

    @State private var range: InsightRange = .week

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }

    private var entriesInRange: [JournalEntry] {
        guard let days = range.days,
              let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date()))
        else { return store.entries }
        return store.entries.filter { $0.timestamp >= start }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Einblicke")
                .font(.display(30))
                .tracking(-0.8)
                .padding(.top, 6)
                .padding(.bottom, 12)

            if store.entries.isEmpty {
                Spacer()
                Text("Noch keine Daten.\nSpeichere ein paar Gefühle – hier siehst du dann,\nwas dich in letzter Zeit bewegt.")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColor.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                Spacer()
                Button(action: onNew) {
                    Text("Gefühl finden")
                        .font(.display(17))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(AppColor.highlight)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 4)
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        Picker("Zeitraum", selection: $range) {
                            ForEach(InsightRange.allCases) { r in
                                Text(r.title).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)

                        statTiles
                        coreChart
                        calendarCard
                        dayTimeChart
                        topWords
                    }
                    .padding(.bottom, 12)
                }
            }
        }
    }

    // MARK: - Stat tiles

    private var statTiles: some View {
        let streak = JournalStats.streak(store.entries)
        return HStack(spacing: 10) {
            StatTile(value: "\(entriesInRange.count)", label: entriesInRange.count == 1 ? "Eintrag" : "Einträge")
            StatTile(value: "\(streak)", label: streak == 1 ? "Tag in Folge" : "Tage in Folge")
            StatTile(value: "\(activeDays)", label: activeDays == 1 ? "aktiver Tag" : "aktive Tage")
        }
    }

    private var activeDays: Int {
        Set(entriesInRange.map { calendar.startOfDay(for: $0.timestamp) }).count
    }

    // MARK: - Core feelings

    private struct CoreCount: Identifiable {
        let name: String
        let hex: String
        let count: Int
        var id: String { name }
    }

    private var coreCounts: [CoreCount] {
        EmotionWheelData.core.map { core in
            CoreCount(name: core.name, hex: core.hex,
                      count: entriesInRange.filter { $0.coreName == core.name }.count)
        }
    }

    private var coreChart: some View {
        InsightCard(title: "Grundgefühle", subtitle: dominantCoreText) {
            if entriesInRange.isEmpty {
                emptyRangeText
            } else {
                Chart(coreCounts) { item in
                    BarMark(
                        x: .value("Anzahl", item.count),
                        y: .value("Gefühl", item.name)
                    )
                    .foregroundStyle(Color(hex: item.hex))
                    .cornerRadius(5)
                    .annotation(position: .trailing) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppColor.muted)
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 12))
                            .foregroundStyle(AppColor.bodyText)
                    }
                }
                .frame(height: 210)
            }
        }
    }

    private var dominantCoreText: String? {
        guard let top = coreCounts.max(by: { $0.count < $1.count }), top.count > 0 else { return nil }
        return "Am häufigsten: \(top.name)"
    }

    // MARK: - Calendar

    /// Last five weeks, Monday-first; each day shows the colour of its most recent feeling.
    private var calendarCard: some View {
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let firstDay = calendar.date(byAdding: .day, value: -28, to: weekStart) ?? weekStart
        let days = (0..<35).compactMap { calendar.date(byAdding: .day, value: $0, to: firstDay) }
        let latestByDay = Dictionary(grouping: store.entries) { calendar.startOfDay(for: $0.timestamp) }
            .compactMapValues { JournalStats.latest($0) }
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

        return InsightCard(title: "Kalender", subtitle: "Letzte 5 Wochen") {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"], id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColor.muted)
                }
                ForEach(days, id: \.self) { day in
                    let entry = latestByDay[day]
                    let isFuture = day > today
                    RoundedRectangle(cornerRadius: 7)
                        .fill(entry.map { Color(hex: $0.colorHex) } ?? AppColor.line.opacity(isFuture ? 0.35 : 1))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 11, weight: day == today ? .bold : .regular))
                                .foregroundStyle(entry == nil ? AppColor.muted : AppColor.ink)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(day == today ? AppColor.highlight : .clear, lineWidth: 2)
                        )
                }
            }
        }
    }

    // MARK: - Time of day

    private enum DayTime: String, CaseIterable {
        case morning = "Morgen", midday = "Mittag", evening = "Abend", night = "Nacht"

        init(hour: Int) {
            switch hour {
            case 5..<11: self = .morning
            case 11..<17: self = .midday
            case 17..<22: self = .evening
            default: self = .night
            }
        }
    }

    private struct DayTimeCount: Identifiable {
        let name: String
        let count: Int
        var id: String { name }
    }

    private var dayTimeChart: some View {
        let counts = DayTime.allCases.map { time in
            DayTimeCount(
                name: time.rawValue,
                count: entriesInRange.filter { DayTime(hour: calendar.component(.hour, from: $0.timestamp)) == time }.count
            )
        }
        return InsightCard(title: "Tageszeit", subtitle: "Wann du eincheckst") {
            if entriesInRange.isEmpty {
                emptyRangeText
            } else {
                Chart(counts) { item in
                    BarMark(
                        x: .value("Tageszeit", item.name),
                        y: .value("Anzahl", item.count)
                    )
                    .foregroundStyle(AppColor.highlight.gradient)
                    .cornerRadius(5)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(AppColor.line)
                        AxisValueLabel().font(.system(size: 11))
                    }
                }
                .frame(height: 150)
            }
        }
    }

    // MARK: - Words

    private struct WordCount: Identifiable {
        let word: String
        let count: Int
        let hex: String
        var id: String { word }
    }

    private var topWords: some View {
        let words = Array(
            Dictionary(grouping: entriesInRange, by: \.word)
                .map { WordCount(word: $0.key, count: $0.value.count, hex: $0.value[0].colorHex) }
                .sorted { $0.count != $1.count ? $0.count > $1.count : $0.word < $1.word }
                .prefix(5)
        )

        return InsightCard(title: "Deine Worte", subtitle: "Am häufigsten gewählt") {
            if words.isEmpty {
                emptyRangeText
            } else {
                VStack(spacing: 8) {
                    ForEach(words) { item in
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: item.hex)).frame(width: 10, height: 10)
                            Text(item.word)
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Text("\(item.count)×")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColor.muted)
                        }
                    }
                }
            }
        }
    }

    private var emptyRangeText: some View {
        Text("Keine Einträge in diesem Zeitraum.")
            .font(.system(size: 13.5))
            .foregroundStyle(AppColor.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum InsightRange: String, CaseIterable, Identifiable {
    case week, month, all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: return "7 Tage"
        case .month: return "30 Tage"
        case .all: return "Alle"
        }
    }

    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .all: return nil
        }
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.display(26))
                .tracking(-0.5)
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(AppColor.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColor.line))
    }
}

struct InsightCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.display(18))
                    .tracking(-0.3)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12.5))
                        .foregroundStyle(AppColor.muted)
                }
            }
            content
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColor.line))
    }
}
