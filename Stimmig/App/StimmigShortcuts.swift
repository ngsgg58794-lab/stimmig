import AppIntents

/// Siri phrases, e.g. „Wie fühle ich mich mit stimmig“.
struct StimmigShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenWheelIntent(),
            phrases: [
                "Wie fühle ich mich mit \(.applicationName)",
                "Gefühl finden mit \(.applicationName)",
                "Einchecken mit \(.applicationName)",
            ]
        )
    }
}
