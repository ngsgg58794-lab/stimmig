import Foundation
import LocalAuthentication

/// Optional Face ID / passcode lock for the journal and insights.
@MainActor
final class AppLock: ObservableObject {
    @Published private(set) var isUnlocked = false

    var isEnabled: Bool { LockSettings.isEnabled }

    /// Name of the available biometry, for UI labels.
    static var biometryName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Code"
        }
    }

    /// Falls back to the device passcode if biometrics fail or aren't set up.
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return false }
        return (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)) ?? false
    }

    /// Returns true if the protected screens may be shown.
    func unlockIfNeeded() async -> Bool {
        guard isEnabled, !isUnlocked else { return true }
        isUnlocked = await Self.authenticate(reason: "Entsperre dein Tagebuch.")
        return isUnlocked
    }

    func lock() {
        isUnlocked = false
    }
}
