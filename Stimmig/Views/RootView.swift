import SwiftUI

enum Step: Equatable {
    case start, core, secondary, tertiary, result, journal, insights, settings

    /// Screens opened from the top bar; "zurück" returns to where they were opened from.
    static let overlays: [Step] = [.journal, .insights, .settings]
}

struct RootView: View {
    @StateObject private var journalStore = JournalStore()

    @State private var step: Step = .start
    @State private var coreIndex: Int?
    @State private var subIndex: Int?
    @State private var wordIndex: Int?
    @State private var returnStep: Step = .start
    @State private var note: String = ""

    private var selectedCore: CoreEmotion? {
        coreIndex.map { EmotionWheelData.core[$0] }
    }
    private var selectedSub: SubEmotion? {
        guard let core = selectedCore, let si = subIndex else { return nil }
        return core.subs[si]
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                step: step,
                onBack: goBack,
                onOpen: openScreen
            )
            .padding(.horizontal, 22)
            .padding(.top, 8)

            Group {
                switch step {
                case .start:
                    StartView(onStart: startFresh)

                case .core, .secondary, .tertiary:
                    WheelScreenView(
                        step: step,
                        core: selectedCore,
                        sub: selectedSub,
                        onPickCore: { i in coreIndex = i; subIndex = nil; wordIndex = nil; step = .secondary },
                        onPickSub: { i in subIndex = i; wordIndex = nil; step = .tertiary },
                        onPickWord: { i in wordIndex = i; note = ""; step = .result }
                    )

                case .result:
                    if let core = selectedCore, let sub = selectedSub, let wi = wordIndex {
                        ResultView(
                            core: core, sub: sub, word: sub.words[wi], note: $note,
                            onSave: { saveEntry(core: core, sub: sub, word: sub.words[wi]) },
                            onAgain: startFresh
                        )
                    }

                case .journal:
                    JournalView(store: journalStore, onNew: startFresh)

                case .insights:
                    InsightsView(store: journalStore, onNew: startFresh)

                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 22)
        }
        .background(AppColor.background.ignoresSafeArea())
        .onOpenURL { url in
            // Widget tap: stimmig://new jumps straight into the wheel.
            if url.host == "new" { startFresh() }
        }
    }

    private func openScreen(_ target: Step) {
        if !Step.overlays.contains(step) { returnStep = step }
        step = target
    }

    private func startFresh() {
        coreIndex = nil
        subIndex = nil
        wordIndex = nil
        step = .core
    }

    private func goBack() {
        switch step {
        case .journal, .insights, .settings:
            step = returnStep
        case .core:
            step = .start
        case .secondary:
            coreIndex = nil
            step = .core
        case .tertiary:
            subIndex = nil
            step = .secondary
        default:
            break
        }
    }

    private func saveEntry(core: CoreEmotion, sub: SubEmotion, word: String) {
        let entry = JournalEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            coreName: core.name,
            subName: sub.name,
            word: word,
            colorHex: core.hex,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        journalStore.add(entry)
        HealthSettings.saveIfEnabled(entry)
    }
}
