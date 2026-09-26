import Foundation
import UserNotifications

/// Daily local reminder to check in. No server involved.
enum Reminder {
    static let enabledKey = "reminderEnabled"
    static let hourKey = "reminderHour"
    static let minuteKey = "reminderMinute"

    private static let requestID = "stimmig.daily-reminder"

    /// Asks for permission if needed and schedules the reminder. Returns false if notifications are denied.
    static func enable(hour: Int, minute: Int) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return false }
        schedule(hour: hour, minute: minute)
        return true
    }

    static func schedule(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Wie fühlst du dich gerade?"
        content.body = "Nimm dir einen Moment und finde das Wort, das passt."
        content.sound = .default

        var time = DateComponents()
        time.hour = hour
        time.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
        center.add(request)
    }

    static func disable() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestID])
    }
}
