import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                print("[NotificationManager] Authorization denied")
            }
        }
    }

    static func sendVoltageAlert(name: String, voltage: Double, unit: String, min: Double, max: Double) {
        let content = UNMutableNotificationContent()
        content.title = L10n("voltage_alert_title")
        content.body = "\(name): \(String(format: "%.1f", voltage)) \(unit) (\(Int(min))–\(Int(max)) \(unit))"
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: "ups-voltage-alert",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to send alert: \(error)")
            }
        }
    }
}
