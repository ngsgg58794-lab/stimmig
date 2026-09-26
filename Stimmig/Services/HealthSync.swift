import Foundation
import HealthKit

enum HealthSettings {
    static let enabledKey = "healthEnabled"

    /// State of Mind logging needs iOS 18 and a device with Apple Health.
    static var isSupported: Bool {
        if #available(iOS 18.0, *) {
            return HKHealthStore.isHealthDataAvailable()
        }
        return false
    }

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    /// Writes the entry to Apple Health if the user turned it on. Silently does nothing otherwise.
    static func saveIfEnabled(_ entry: JournalEntry) {
        guard isEnabled else { return }
        if #available(iOS 18.0, *) {
            Task { await HealthSync.save(entry) }
        }
    }
}

/// Writes journal entries to Apple Health as "State of Mind" samples (write-only, nothing is read).
@available(iOS 18.0, *)
enum HealthSync {
    private static let store = HKHealthStore()

    /// Shows the Health permission sheet. Returns true if writing State of Mind is allowed.
    static func requestAuthorization() async -> Bool {
        let type = HKObjectType.stateOfMindType()
        do {
            try await store.requestAuthorization(toShare: [type], read: [])
        } catch {
            return false
        }
        return store.authorizationStatus(for: type) == .sharingAuthorized
    }

    static func save(_ entry: JournalEntry) async {
        let mood = StateOfMindMapping.mood(core: entry.coreName, sub: entry.subName)
        let sample = HKStateOfMind(
            date: entry.timestamp,
            kind: .momentaryEmotion,
            valence: mood.valence,
            labels: mood.labels,
            associations: []
        )
        try? await store.save(sample)
    }
}

/// Maps the wheel's German feelings onto Health's State of Mind labels and valence (-1 … 1).
@available(iOS 18.0, *)
enum StateOfMindMapping {
    struct Mood {
        let labels: [HKStateOfMind.Label]
        let valence: Double
    }

    static func mood(core: String, sub: String) -> Mood {
        bySub["\(core)|\(sub)"] ?? byCore[core] ?? Mood(labels: [], valence: 0)
    }

    private static let byCore: [String: Mood] = [
        "liebend": Mood(labels: [.content], valence: 0.7),
        "überrascht": Mood(labels: [.surprised], valence: 0.2),
        "zornig": Mood(labels: [.angry], valence: -0.7),
        "furchtsam": Mood(labels: [.scared], valence: -0.7),
        "traurig": Mood(labels: [.sad], valence: -0.7),
        "freudig": Mood(labels: [.happy], valence: 0.8),
    ]

    private static let bySub: [String: Mood] = [
        "liebend|friedlich": Mood(labels: [.peaceful, .calm], valence: 0.7),
        "liebend|liebevoll": Mood(labels: [.content, .happy], valence: 0.8),
        "liebend|romantisch": Mood(labels: [.passionate], valence: 0.8),
        "liebend|dankbar": Mood(labels: [.grateful], valence: 0.8),
        "liebend|sentimental": Mood(labels: [.content], valence: 0.4),
        "liebend|verzaubert": Mood(labels: [.amazed], valence: 0.8),

        "überrascht|überwältigt": Mood(labels: [.overwhelmed], valence: 0.0),
        "überrascht|bewegt": Mood(labels: [.amazed], valence: 0.5),
        "überrascht|erschrocken": Mood(labels: [.surprised, .scared], valence: -0.3),
        "überrascht|aufgeregt": Mood(labels: [.excited], valence: 0.6),
        "überrascht|erstaunt": Mood(labels: [.amazed, .surprised], valence: 0.4),
        "überrascht|verwirrt": Mood(labels: [.surprised], valence: -0.1),

        "zornig|wütend": Mood(labels: [.angry], valence: -0.8),
        "zornig|eifersüchtig": Mood(labels: [.jealous], valence: -0.6),
        "zornig|angeekelt": Mood(labels: [.disgusted], valence: -0.7),
        "zornig|kritisch": Mood(labels: [.annoyed], valence: -0.3),
        "zornig|reizbar": Mood(labels: [.irritated], valence: -0.5),
        "zornig|hasserfüllt": Mood(labels: [.angry], valence: -0.9),

        "furchtsam|erschrocken": Mood(labels: [.scared], valence: -0.7),
        "furchtsam|unsicher": Mood(labels: [.anxious], valence: -0.5),
        "furchtsam|nervös": Mood(labels: [.worried, .anxious], valence: -0.5),
        "furchtsam|entsetzt": Mood(labels: [.scared, .ashamed], valence: -0.8),
        "furchtsam|abgelehnt": Mood(labels: [.lonely, .discouraged], valence: -0.6),
        "furchtsam|verängstigt": Mood(labels: [.scared, .anxious], valence: -0.8),

        "traurig|einsam": Mood(labels: [.lonely], valence: -0.6),
        "traurig|verletzt": Mood(labels: [.sad], valence: -0.6),
        "traurig|deprimiert": Mood(labels: [.sad, .drained], valence: -0.8),
        "traurig|gelangweilt": Mood(labels: [.indifferent], valence: -0.2),
        "traurig|schuldbewusst": Mood(labels: [.guilty], valence: -0.6),
        "traurig|verzweifelt": Mood(labels: [.hopeless], valence: -0.9),

        "freudig|optimistisch": Mood(labels: [.hopeful], valence: 0.7),
        "freudig|glücklich": Mood(labels: [.happy], valence: 0.8),
        "freudig|stolz": Mood(labels: [.proud], valence: 0.8),
        "freudig|gut gelaunt": Mood(labels: [.amused, .happy], valence: 0.7),
        "freudig|erfreut": Mood(labels: [.satisfied], valence: 0.7),
        "freudig|euphorisch": Mood(labels: [.joyful, .excited], valence: 0.9),
    ]
}
