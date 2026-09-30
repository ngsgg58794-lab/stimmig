import WidgetKit
import SwiftUI

struct MoodSnapshot: TimelineEntry {
    let date: Date
    let latest: JournalEntry?
    let streak: Int
    /// Journal lock is on: show the colour but not the word.
    var locked = false

    static let sample = MoodSnapshot(
        date: Date(),
        latest: JournalEntry(
            id: "sample", timestamp: Date(), coreName: "freudig", subName: "glücklich",
            word: "vergnügt", colorHex: "#C2CF74", note: ""
        ),
        streak: 3
    )
}

struct MoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoodSnapshot {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodSnapshot) -> Void) {
        completion(context.isPreview ? .sample : current())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodSnapshot>) -> Void) {
        // The app reloads the widget on every save; refresh after midnight so "heute" and the streak roll over.
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
        completion(Timeline(entries: [current()], policy: .after(tomorrow.addingTimeInterval(60))))
    }

    private func current() -> MoodSnapshot {
        let entries = JournalFile.load()
        return MoodSnapshot(
            date: Date(), latest: JournalStats.latest(entries),
            streak: JournalStats.streak(entries), locked: LockSettings.isEnabled
        )
    }
}

struct StimmigWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: MoodSnapshot

    /// The word to show, or a placeholder while the journal is locked.
    private func word(_ entry: JournalEntry) -> String {
        snapshot.locked ? "•••" : entry.word
    }

    private var isToday: Bool {
        guard let latest = snapshot.latest else { return false }
        return Calendar.current.isDate(latest.timestamp, inSameDayAs: snapshot.date)
    }

    var body: some View {
        content
            .widgetURL(URL(string: "stimmig://new"))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(snapshot.streak)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            .widgetBackground(Color.clear, padded: false)

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(isToday ? "Heute" : "Wie fühlst du dich?")
                    .font(.system(size: 12, weight: .semibold))
                    .widgetAccentable()
                Text(isToday ? snapshot.latest.map(word) ?? "" : "Tippe zum Einchecken")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .lineLimit(1)
                if snapshot.streak > 0 {
                    Label(JournalStats.streakLabel(snapshot.streak), systemImage: "flame.fill")
                        .font(.system(size: 12))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetBackground(Color.clear, padded: false)

        case .accessoryInline:
            Text(isToday ? "stimmig: \(snapshot.latest.map(word) ?? "")" : "stimmig: Wie fühlst du dich?")
                .widgetBackground(Color.clear, padded: false)

        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        let tint = snapshot.latest.map { Color(hex: $0.colorHex) } ?? AppColor.highlight
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Circle().fill(tint).frame(width: 9, height: 9)
                Text("stimmig")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.onEmotion)
            }
            Spacer(minLength: 6)
            if let latest = snapshot.latest {
                Text(isToday ? "HEUTE" : "ZULETZT")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(AppColor.onEmotion.opacity(0.6))
                Text(word(latest))
                    .font(.display(24))
                    .tracking(-0.6)
                    .foregroundStyle(AppColor.onEmotion)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(latest.coreName)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.onEmotion.opacity(0.8))
            } else {
                Text("Wie fühlst du dich?")
                    .font(.display(19))
                    .foregroundStyle(AppColor.onEmotion)
            }
            Spacer(minLength: 6)
            if snapshot.streak > 0 {
                Label(JournalStats.streakLabel(snapshot.streak), systemImage: "flame.fill")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(AppColor.highlight)
            } else {
                Text("Tippe zum Einchecken")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(AppColor.highlight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetBackground(tint.mixedWithWhite(0.78))
    }
}

private extension View {
    /// iOS 17+ requires `containerBackground`; older systems use a plain background.
    @ViewBuilder
    func widgetBackground(_ color: Color, padded: Bool = true) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else if padded {
            padding().background(color)
        } else {
            background(color)
        }
    }
}

struct StimmigWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StimmigWidget", provider: MoodProvider()) { snapshot in
            StimmigWidgetView(snapshot: snapshot)
        }
        .configurationDisplayName("stimmig")
        .description("Dein letztes Gefühl und deine Serie – ein Tipp öffnet das Gefühlsrad.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

@main
struct StimmigWidgetBundle: WidgetBundle {
    var body: some Widget {
        StimmigWidget()
        if #available(iOS 18.0, *) {
            StimmigControl()
        }
    }
}
