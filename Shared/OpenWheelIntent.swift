import AppIntents
import Foundation

/// Opens stimmig directly on the feelings wheel — used by Siri/Shortcuts and the Control Center button.
struct OpenWheelIntent: AppIntent {
    static var title: LocalizedStringResource = "Gefühl finden"
    static var description = IntentDescription("Öffnet stimmig direkt im Gefühlsrad.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        OpenWheelRequest.post()
        return .result()
    }
}

/// Hand-off between the intent (which may run in the widget extension) and the app.
enum OpenWheelRequest {
    static let notification = Notification.Name("stimmig.openWheelRequested")
    private static let key = "openWheelRequested"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: AppGroup.id) }

    static func post() {
        defaults?.set(true, forKey: key)
        NotificationCenter.default.post(name: notification, object: nil)
    }

    /// True once per request; clears the flag.
    static func consume() -> Bool {
        guard defaults?.bool(forKey: key) == true else { return false }
        defaults?.set(false, forKey: key)
        return true
    }
}
