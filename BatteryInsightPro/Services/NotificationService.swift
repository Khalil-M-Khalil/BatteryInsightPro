// NotificationService.swift
// Battery Insight Pro

import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleLowBatteryAlert(level: Double) {
        guard level < 0.2 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Low Battery"
        content.body  = "Battery is at \(Int(level * 100))%. Plug in your charger soon."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "lowBattery", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleHighThermalAlert(state: ProcessInfo.ThermalState) {
        guard state == .serious || state == .critical else { return }
        let content = UNMutableNotificationContent()
        content.title = "Device Overheating"
        content.body  = "Your device is running hot (\(state.displayName)). Stop charging and move to a cool area."
        content.sound = .defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "highTemp", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleStorageAlert(freePercent: Double) {
        guard freePercent < 10 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Storage Almost Full"
        content.body  = "Only \(Int(freePercent))% storage remaining. Open Battery Insight Pro to clean up."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "lowStorage", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleCalibrationReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Battery Calibration Reminder"
        content.body  = "For best results, fully charge your battery once this month."
        content.sound = .default
        // Schedule for 30 days
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 24 * 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "calibration", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
