import SwiftUI
import UIKit
import WidgetKit

struct SettingsView: View {
    @AppStorage(Reminder.enabledKey) private var reminderEnabled = false
    @AppStorage(Reminder.hourKey) private var reminderHour = 20
    @AppStorage(Reminder.minuteKey) private var reminderMinute = 0
    @AppStorage(HealthSettings.enabledKey) private var healthEnabled = false
    @AppStorage(LockSettings.enabledKey, store: LockSettings.store) private var lockEnabled = false

    @State private var notificationsDenied = false
    @State private var healthDenied = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderHour = parts.hour ?? 20
                reminderMinute = parts.minute ?? 0
                if reminderEnabled {
                    Reminder.schedule(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Einstellungen")
                .font(.display(30))
                .tracking(-0.8)
                .padding(.top, 6)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 14) {
                    reminderCard
                    lockCard
                    if HealthSettings.isSupported {
                        healthCard
                    }
                    privacyCard
                }
                .padding(.bottom, 12)
            }
        }
    }

    private var reminderCard: some View {
        InsightCard(title: "Tägliche Erinnerung", subtitle: "Ein sanfter Anstoß, kurz innezuhalten.") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: Binding(get: { reminderEnabled }, set: setReminder)) {
                    Text("Erinnerung aktiv")
                        .font(.system(size: 15, weight: .semibold))
                }
                .tint(AppColor.highlight)

                if reminderEnabled {
                    DatePicker("Uhrzeit", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 15))
                        .environment(\.locale, Locale(identifier: "de_DE"))
                }

                if notificationsDenied {
                    deniedHint("Mitteilungen sind für stimmig ausgeschaltet. Du kannst sie in den iOS-Einstellungen erlauben.")
                }
            }
        }
    }

    private var healthCard: some View {
        InsightCard(title: "Apple Health", subtitle: "Gefundene Gefühle als „Gemütszustand“ in der Health-App sichern.") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: Binding(get: { healthEnabled }, set: setHealth)) {
                    Text("In Health speichern")
                        .font(.system(size: 15, weight: .semibold))
                }
                .tint(AppColor.highlight)

                Text("stimmig schreibt nur neue Einträge in Health und liest keine Gesundheitsdaten.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(AppColor.muted)

                if healthDenied {
                    deniedHint("Kein Schreibzugriff. Erlaube ihn in der Health-App unter Profil › Apps › stimmig.")
                }
            }
        }
    }

    private var lockCard: some View {
        let biometry = AppLock.biometryName
        return InsightCard(title: "Tagebuch sperren", subtitle: "Tagebuch und Einblicke nur mit \(biometry) öffnen.") {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(get: { lockEnabled }, set: setLock)) {
                    Text("Mit \(biometry) schützen")
                        .font(.system(size: 15, weight: .semibold))
                }
                .tint(AppColor.highlight)

                if lockEnabled {
                    Text("Das Widget zeigt dann kein Gefühlswort mehr an.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(AppColor.muted)
                }
            }
        }
    }

    private var privacyCard: some View {
        InsightCard(title: "Privatsphäre", subtitle: nil) {
            Text("Kein Konto, keine Werbung, kein Tracking. Deine Einträge bleiben auf deinem iPhone.")
                .font(.system(size: 13.5))
                .foregroundStyle(AppColor.bodyText)
        }
    }

    private func deniedHint(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.system(size: 12.5))
                .foregroundStyle(AppColor.muted)
            Button("iOS-Einstellungen öffnen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(AppColor.highlight)
        }
    }

    private func setReminder(_ on: Bool) {
        guard on else {
            reminderEnabled = false
            notificationsDenied = false
            Reminder.disable()
            return
        }
        Task { @MainActor in
            let granted = await Reminder.enable(hour: reminderHour, minute: reminderMinute)
            reminderEnabled = granted
            notificationsDenied = !granted
        }
    }

    /// Turning the lock on or off both require authenticating once.
    private func setLock(_ on: Bool) {
        Task { @MainActor in
            let reason = on ? "Tagebuch-Sperre aktivieren." : "Tagebuch-Sperre deaktivieren."
            guard await AppLock.authenticate(reason: reason) else { return }
            lockEnabled = on
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func setHealth(_ on: Bool) {
        guard on else {
            healthEnabled = false
            healthDenied = false
            return
        }
        guard #available(iOS 18.0, *) else { return }
        Task { @MainActor in
            let granted = await HealthSync.requestAuthorization()
            healthEnabled = granted
            healthDenied = !granted
        }
    }
}
