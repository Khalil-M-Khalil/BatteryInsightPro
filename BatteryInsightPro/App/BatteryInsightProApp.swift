// BatteryInsightProApp.swift
// Battery Insight Pro
// Entry point — sets up Core Data, notifications, and battery monitoring

import SwiftUI
import UserNotifications

@main
struct BatteryInsightProApp: App {

    @StateObject private var batteryVM    = BatteryViewModel()
    @StateObject private var systemVM     = SystemViewModel()
    @StateObject private var storageVM    = StorageViewModel()
    @StateObject private var performanceVM = PerformanceViewModel()
    @StateObject private var diagnosticsVM = DiagnosticsViewModel()
    @StateObject private var settingsVM   = SettingsViewModel()
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(batteryVM)
                .environmentObject(systemVM)
                .environmentObject(storageVM)
                .environmentObject(performanceVM)
                .environmentObject(diagnosticsVM)
                .environmentObject(settingsVM)
                .preferredColorScheme(settingsVM.colorScheme)
        }
    }
}
