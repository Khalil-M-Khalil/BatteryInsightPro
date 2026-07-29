// SettingsView.swift
// Battery Insight Pro

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var showAbout = false

    var body: some View {
        ZStack {
            BIPBackground()
            List {
                // Appearance
                Section {
                    Picker("Theme", selection: $settingsVM.themeMode) {
                        Text("Automatic").tag("auto")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.menu)

                    Picker("Temperature Unit", selection: $settingsVM.temperatureUnit) {
                        Text("Celsius (°C)").tag("celsius")
                        Text("Fahrenheit (°F)").tag("fahrenheit")
                    }
                    .pickerStyle(.menu)
                } header: { Text("Appearance") }

                // Monitoring
                Section {
                    Picker("Refresh Interval", selection: $settingsVM.refreshInterval) {
                        Text("1 second").tag(1)
                        Text("5 seconds").tag(5)
                        Text("10 seconds").tag(10)
                        Text("30 seconds").tag(30)
                    }
                    .pickerStyle(.menu)
                } header: { Text("Monitoring") }

                // Notifications
                Section {
                    Toggle("Enable Notifications", isOn: $settingsVM.notificationsEnabled)
                    if settingsVM.notificationsEnabled {
                        Button("Schedule Calibration Reminder") {
                            NotificationService.shared.scheduleCalibrationReminder()
                        }
                        .foregroundStyle(Color.bip.accent)
                    }
                } header: { Text("Notifications") }

                // Reports
                Section {
                    Picker("Report Language", selection: $settingsVM.reportLanguage) {
                        Text("English").tag("English")
                        Text("Arabic").tag("Arabic")
                    }
                    .pickerStyle(.menu)
                } header: { Text("Reports") }

                // API Transparency
                Section {
                    NavigationLink("API Transparency") {
                        APITransparencyView()
                    }
                } header: { Text("Privacy & Transparency") }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("100").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Target iOS")
                        Spacer()
                        Text("16.0+").foregroundStyle(.secondary)
                    }
                } header: { Text("About") }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct APITransparencyView: View {
    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: BIPSpacing.lg) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: BIPSpacing.md) {
                            Label("Live Metrics (🟢)", systemImage: "circle.fill")
                                .font(BIPFont.headline())
                                .foregroundStyle(Color.bip.green)
                            Text("These values are read directly from public iOS APIs:\n• Battery Level — UIDevice.batteryLevel\n• Charging State — UIDevice.batteryState\n• Low Power Mode — ProcessInfo.isLowPowerModeEnabled\n• Thermal State — ProcessInfo.thermalState\n• Device Model / OS Version — UIDevice / ProcessInfo\n• CPU Usage — host_statistics (Darwin)\n• RAM Usage — host_statistics64 (Darwin)\n• Storage — FileManager volume attributes")
                                .font(BIPFont.body())
                                .foregroundStyle(.secondary)
                        }
                    }.padding(.horizontal)

                    GlassCard {
                        VStack(alignment: .leading, spacing: BIPSpacing.md) {
                            Label("Estimated Metrics (🟡)", systemImage: "waveform")
                                .font(BIPFont.headline())
                                .foregroundStyle(Color.bip.yellow)
                            Text("These values are derived or calculated from observable data:\n• Battery Health % — estimated from discharge/charge patterns\n• Screen/Standby Time — estimated from current level\n• Charging Efficiency — estimated from session data\n• Wear Level — 100% minus estimated health\n• Lifetime Prediction — heuristic model\n• Battery Chemistry — assumed from device generation")
                                .font(BIPFont.body())
                                .foregroundStyle(.secondary)
                        }
                    }.padding(.horizontal)

                    GlassCard {
                        VStack(alignment: .leading, spacing: BIPSpacing.md) {
                            Label("Unavailable Metrics (🔴)", systemImage: "slash.circle")
                                .font(BIPFont.headline())
                                .foregroundStyle(Color.gray)
                            Text("These values require private IOKit entitlements that are not available to App Store apps:\n• Battery Temperature — IOKit private\n• Battery Voltage — IOKit private\n• Battery Current (mA) — IOKit private\n• Battery Cycle Count — IOKit private\n• Manufacture Date — IOKit private\n• Design / Max Capacity (mAh) — IOKit private\n• Charging Speed (W) — IOKit private\n• GPU Usage — Private Metal API\n• Per-App Battery Drain — Private daemon\n• Frame Rate (FPS) — Private CA API")
                                .font(BIPFont.body())
                                .foregroundStyle(.secondary)
                        }
                    }.padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("API Transparency")
    }
}
