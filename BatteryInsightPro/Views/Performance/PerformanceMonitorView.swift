// PerformanceMonitorView.swift
// Battery Insight Pro — real-time 1s charts

import SwiftUI
import Charts

struct PerformanceMonitorView: View {
    @EnvironmentObject var performanceVM: PerformanceViewModel
    @EnvironmentObject var batteryVM: BatteryViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BIPBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: BIPSpacing.lg) {
                        liveSummary
                        cpuChart
                        ramChart
                        batteryChart
                        thermalCard
                        unavailableNote
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Performance")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var liveSummary: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: BIPSpacing.sm) {
            miniStatCard(title: "CPU",
                         value: String(format: "%.0f%%", performanceVM.currentCPU),
                         color: performanceVM.cpuGradient.first ?? Color.bip.purple,
                         icon: "cpu")
            miniStatCard(title: "RAM",
                         value: performanceVM.ramUsedLabel,
                         color: Color.bip.accent,
                         icon: "memorychip")
            miniStatCard(title: "Battery",
                         value: String(format: "%.0f%%", performanceVM.batteryLevel),
                         color: Color.bip.green,
                         icon: "battery.100")
        }
    }

    private func miniStatCard(title: String, value: String, color: Color, icon: String) -> some View {
        AccentCard(gradient: [color, color.opacity(0.6)]) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(BIPFont.headline(weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(BIPFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var cpuChart: some View {
        GlassCard {
            LiveLineChart(
                data: performanceVM.cpuHistory,
                color: performanceVM.cpuGradient.first ?? Color.bip.purple,
                title: "CPU Usage",
                unit: "%"
            )
        }
    }

    private var ramChart: some View {
        GlassCard {
            LiveLineChart(
                data: performanceVM.ramHistory,
                color: Color.bip.accent,
                title: "RAM Usage",
                unit: "%"
            )
        }
    }

    private var batteryChart: some View {
        GlassCard {
            LiveLineChart(
                data: performanceVM.batteryHistory,
                color: Color.bip.green,
                title: "Battery Level",
                unit: "%",
                minY: 0,
                maxY: 100
            )
        }
    }

    private var thermalCard: some View {
        GlassCard {
            HStack(spacing: BIPSpacing.md) {
                Image(systemName: performanceVM.thermalState.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(performanceVM.thermalColor)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thermal State")
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                    Text(performanceVM.thermalState.displayName)
                        .font(BIPFont.headline())
                }
                Spacer()
                if ProcessInfo.processInfo.isLowPowerModeEnabled {
                    StatusPill(text: "Low Power", color: Color.bip.yellow, icon: "bolt.slash")
                }
            }
        }
    }

    private var unavailableNote: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Restricted Metrics", icon: "lock.fill", iconColor: Color.gray)
                MetricRow(icon: "display",    title: "GPU Usage",    value: "N/A", availability: .unavailable, iconColor: Color.gray, detail: "GPU metrics require private Metal Performance Shaders entitlements")
                Divider().opacity(0.2)
                MetricRow(icon: "wifi",       title: "Wi-Fi Quality",value: "N/A", availability: .unavailable, iconColor: Color.gray, detail: "Network quality metrics require private NetworkExtension entitlements")
                Divider().opacity(0.2)
                MetricRow(icon: "antenna.radiowaves.left.and.right", title: "Cellular Quality", value: "N/A", availability: .unavailable, iconColor: Color.gray, detail: "Requires CoreTelephony private entitlements")
                Divider().opacity(0.2)
                MetricRow(icon: "film",       title: "Frame Rate (FPS)",value: "N/A", availability: .unavailable, iconColor: Color.gray, detail: "CADisplayLink FPS is available but rendering FPS across the OS is private")
            }
        }
    }
}
