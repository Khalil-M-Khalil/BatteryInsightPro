// BatteryDetailView.swift
// Battery Insight Pro — Full battery metrics with availability indicators

import SwiftUI

struct BatteryDetailView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                BIPBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: BIPSpacing.lg) {
                        // Tab picker
                        Picker("", selection: $selectedTab) {
                            Text("Details").tag(0)
                            Text("Diagnostics").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, BIPSpacing.md)

                        if selectedTab == 0 {
                            batteryDetailsContent
                        } else {
                            BatteryDiagnosticsView()
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Battery")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var batteryDetailsContent: some View {
        VStack(spacing: BIPSpacing.lg) {
            GlassCard {
                VStack(spacing: BIPSpacing.md) {
                    SectionHeader(title: "Live Metrics", icon: "bolt.fill", iconColor: Color.bip.green)
                    MetricRow(icon: "battery.100",     title: "Battery Level",      value: batteryVM.levelPercent,    availability: .live,      iconColor: Color.bip.green)
                    Divider().opacity(0.2)
                    MetricRow(icon: batteryVM.info.state.icon, title: "Charging State", value: batteryVM.info.state.rawValue, availability: .live, iconColor: batteryVM.stateColor)
                    Divider().opacity(0.2)
                    MetricRow(icon: "moon.fill",      title: "Low Power Mode",     value: batteryVM.info.isLowPowerMode ? "Active" : "Off", availability: .live, iconColor: Color.bip.yellow)
                    Divider().opacity(0.2)
                    MetricRow(icon: batteryVM.info.thermalState.icon, title: "Thermal State", value: batteryVM.info.thermalState.displayName, availability: .live, iconColor: batteryVM.thermalColor)
                }
            }.padding(.horizontal)

            GlassCard {
                VStack(spacing: BIPSpacing.md) {
                    SectionHeader(title: "Estimated Metrics", icon: "waveform", iconColor: Color.bip.yellow)
                    MetricRow(icon: "heart.fill",     title: "Battery Health",     value: batteryVM.healthPercent,   availability: .estimated, iconColor: Color.bip.accent)
                    Divider().opacity(0.2)
                    MetricRow(icon: "battery.slash",  title: "Wear Level",         value: String(format: "%.1f%%", batteryVM.info.wearLevel), availability: .estimated, iconColor: Color.bip.orange)
                    Divider().opacity(0.2)
                    MetricRow(icon: "iphone",         title: "Screen Time Left",   value: batteryVM.screenTimeLabel, availability: .estimated, iconColor: Color.bip.accent)
                    Divider().opacity(0.2)
                    MetricRow(icon: "moon.stars",     title: "Standby Time Left",  value: batteryVM.standbyTimeLabel, availability: .estimated, iconColor: Color.bip.purple)
                    Divider().opacity(0.2)
                    MetricRow(icon: "bolt.circle",    title: "Charge Efficiency",  value: String(format: "%.0f%%", batteryVM.info.chargingEfficiency), availability: .estimated, iconColor: Color.bip.green)
                    Divider().opacity(0.2)
                    MetricRow(icon: "cpu",            title: "Battery Chemistry",  value: batteryVM.info.chemistry.value, availability: .estimated, iconColor: Color.bip.mint)
                    Divider().opacity(0.2)
                    MetricRow(icon: "clock.arrow.2.circlepath", title: "Lifetime Prediction", value: batteryVM.info.lifetimePrediction, availability: .estimated, iconColor: Color.bip.yellow)
                }
            }.padding(.horizontal)

            GlassCard {
                VStack(spacing: BIPSpacing.md) {
                    SectionHeader(title: "Private API Metrics", icon: "lock.fill", iconColor: Color.gray)
                    Text("The following metrics require private iOS entitlements and cannot be accessed on standard App Store apps. Tap any row for details.")
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                    Group {
                        MetricRow(icon: "thermometer",   title: "Temperature",      value: batteryVM.info.temperature.value,      availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.temperature.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "bolt.fill",     title: "Voltage",          value: batteryVM.info.voltage.value,          availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.voltage.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "amplifier",     title: "Current (mA)",     value: batteryVM.info.currentMilliAmps.value, availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.currentMilliAmps.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "arrow.triangle.2.circlepath", title: "Cycle Count", value: batteryVM.info.cycleCount.value, availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.cycleCount.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "calendar",      title: "Manufacture Date", value: batteryVM.info.manufactureDate.value,  availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.manufactureDate.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "atom",          title: "Design Capacity",  value: batteryVM.info.designCapacity.value,   availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.designCapacity.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "chart.bar.fill",title: "Max Capacity",     value: batteryVM.info.maximumCapacity.value,  availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.maximumCapacity.unavailableReason)
                        Divider().opacity(0.2)
                        MetricRow(icon: "bolt.badge.clock",title: "Charging Speed", value: batteryVM.info.chargingSpeed.value,    availability: .unavailable, iconColor: Color.gray, detail: batteryVM.info.chargingSpeed.unavailableReason)
                    }
                }
            }.padding(.horizontal)
        }
    }
}
