// SystemAnalyzerView.swift
// Battery Insight Pro

import SwiftUI

struct SystemAnalyzerView: View {
    @EnvironmentObject var systemVM: SystemViewModel
    @EnvironmentObject var batteryVM: BatteryViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BIPBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: BIPSpacing.lg) {
                        deviceInfoSection
                        cpuMemSection
                        thermalSection
                        unavailableSection
                        errorsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("System")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { systemVM.refresh() } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Color.bip.accent)
                    }
                }
            }
        }
    }

    // MARK: - Device Info
    private var deviceInfoSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Device Information", icon: "iphone", iconColor: Color.bip.accent)
                MetricRow(icon: "number",         title: "iOS Version",    value: systemVM.info.iOSVersion,      availability: .live, iconColor: Color.bip.accent)
                Divider().opacity(0.2)
                MetricRow(icon: "hammer",         title: "Build Number",   value: systemVM.info.buildNumber,     availability: .live, iconColor: Color.bip.accent)
                Divider().opacity(0.2)
                MetricRow(icon: "iphone",         title: "Device Model",   value: systemVM.info.deviceModel,     availability: .live, iconColor: Color.bip.accent)
                Divider().opacity(0.2)
                MetricRow(icon: "barcode",        title: "Model ID",       value: systemVM.info.modelIdentifier, availability: .live, iconColor: Color.bip.accent)
                Divider().opacity(0.2)
                MetricRow(icon: "clock.fill",     title: "Uptime",         value: systemVM.uptimeLabel,           availability: .live, iconColor: Color.bip.green)
                Divider().opacity(0.2)
                MetricRow(icon: "internaldrive",  title: "Kernel Version", value: systemVM.info.kernelVersion,   availability: .live, iconColor: Color.bip.purple)
                Divider().opacity(0.2)
                MetricRow(icon: "moon.fill",      title: "Low Power Mode", value: systemVM.info.isLowPowerMode ? "On" : "Off", availability: .live, iconColor: Color.bip.yellow)
            }
        }
    }

    // MARK: - CPU & Memory
    private var cpuMemSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "CPU & Memory", icon: "cpu", iconColor: Color.bip.purple)
                HStack(spacing: BIPSpacing.xl) {
                    VStack(spacing: 8) {
                        CircularGauge(
                            value: min(systemVM.info.cpuInfo.usagePercent / 100.0, 1.0),
                            lineWidth: 10,
                            gradient: systemVM.cpuGradient,
                            label: "CPU",
                            valueText: "\(Int(systemVM.info.cpuInfo.usagePercent))%",
                            size: 120
                        )
                    }
                    VStack(spacing: 8) {
                        CircularGauge(
                            value: systemVM.ramPercent,
                            lineWidth: 10,
                            gradient: systemVM.ramGradient,
                            label: "RAM",
                            valueText: systemVM.ramUsedLabel,
                            size: 120
                        )
                    }
                }
                Divider().opacity(0.2)
                Group {
                    MetricRow(icon: "slider.horizontal.3", title: "CPU Cores",      value: "\(systemVM.info.processorCount)", availability: .live, iconColor: Color.bip.purple)
                    Divider().opacity(0.2)
                    MetricRow(icon: "cpu",                title: "Active Cores",   value: "\(systemVM.info.activeProcessorCount)", availability: .live, iconColor: Color.bip.purple)
                    Divider().opacity(0.2)
                    MetricRow(icon: "arrow.up",           title: "User CPU",       value: String(format: "%.1f%%", systemVM.info.cpuInfo.userPercent), availability: .live, iconColor: Color.bip.purple)
                    Divider().opacity(0.2)
                    MetricRow(icon: "gearshape",          title: "System CPU",     value: String(format: "%.1f%%", systemVM.info.cpuInfo.systemPercent), availability: .live, iconColor: Color.bip.accent)
                    Divider().opacity(0.2)
                    MetricRow(icon: "memorychip",         title: "Total RAM",      value: systemVM.ramTotalLabel, availability: .live, iconColor: Color.bip.accent)
                    Divider().opacity(0.2)
                    MetricRow(icon: "chart.bar",          title: "Memory Pressure",value: systemVM.info.memoryInfo.pressureLevel, availability: .live, iconColor: memoryPressureColor)
                    Divider().opacity(0.2)
                    MetricRow(icon: "folder.fill",        title: "File System",    value: systemVM.info.fileSystemHealth, availability: .estimated, iconColor: Color.bip.green)
                    Divider().opacity(0.2)
                    MetricRow(icon: "app.badge",          title: "Background Procs",value: "~\(systemVM.info.backgroundProcessCount)", availability: .estimated, iconColor: Color.bip.orange)
                }
            }
        }
    }

    private var memoryPressureColor: Color {
        switch systemVM.info.memoryInfo.pressureLevel {
        case "Critical": return Color.bip.red
        case "Warning":  return Color.bip.yellow
        default:         return Color.bip.green
        }
    }

    // MARK: - Thermal
    private var thermalSection: some View {
        AccentCard(gradient: thermalGradient) {
            HStack(spacing: BIPSpacing.md) {
                Image(systemName: systemVM.info.thermalState.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(thermalGradient.first ?? Color.bip.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thermal State")
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                    Text(systemVM.info.thermalState.displayName)
                        .font(BIPFont.title2())
                        .foregroundStyle(.primary)
                    Text(thermalDescription)
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                AvailabilityBadge(availability: .live)
            }
        }
    }

    private var thermalGradient: [Color] {
        switch systemVM.info.thermalState {
        case .nominal:  return [Color.bip.green, Color.bip.mint]
        case .fair:     return [Color.bip.yellow, Color.bip.orange]
        case .serious:  return [Color.bip.orange, Color.bip.red]
        case .critical: return Color.bip.dangerGradient
        @unknown default: return [Color.gray, Color.gray]
        }
    }

    private var thermalDescription: String {
        switch systemVM.info.thermalState {
        case .nominal:  return "Device temperature is normal"
        case .fair:     return "Slightly elevated — minor throttling possible"
        case .serious:  return "High temperature — performance is throttled"
        case .critical: return "Critical temperature — severe throttling active"
        @unknown default: return ""
        }
    }

    // MARK: - Unavailable
    private var unavailableSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Restricted Metrics", icon: "lock.fill", iconColor: Color.gray)
                MetricRow(icon: "display",   title: "GPU Usage",    value: systemVM.info.gpuUsage.value,    availability: .unavailable, iconColor: Color.gray, detail: systemVM.info.gpuUsage.unavailableReason)
                Divider().opacity(0.2)
                MetricRow(icon: "internaldrive", title: "Disk Activity", value: systemVM.info.diskActivity.value, availability: .unavailable, iconColor: Color.gray, detail: systemVM.info.diskActivity.unavailableReason)
            }
        }
    }

    // MARK: - Errors
    @ViewBuilder
    private var errorsSection: some View {
        if !systemVM.deviceErrors.isEmpty {
            GlassCard {
                VStack(spacing: BIPSpacing.sm) {
                    SectionHeader(title: "Detected Issues", icon: "exclamationmark.triangle.fill", iconColor: Color.bip.orange)
                    ForEach(systemVM.deviceErrors) { err in
                        ErrorCard(item: err)
                    }
                }
            }
        }
    }
}

struct ErrorCard: View {
    var item: ErrorItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: item.icon)
                    .foregroundStyle(severityColor)
                Text(item.title)
                    .font(BIPFont.body(weight: .semibold))
                Spacer()
                severityBadge
            }
            Text(item.description)
                .font(BIPFont.caption())
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("💡 " + item.recommendation)
                .font(BIPFont.caption(weight: .medium))
                .foregroundStyle(Color.bip.accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BIPSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: BIPRadius.sm)
                .fill(severityColor.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: BIPRadius.sm).stroke(severityColor.opacity(0.2), lineWidth: 1))
        )
    }

    private var severityColor: Color {
        switch item.severity {
        case .low:      return Color.bip.yellow
        case .medium:   return Color.bip.orange
        case .high:     return Color.bip.red
        case .critical: return Color.bip.red
        }
    }

    private var severityBadge: some View {
        Text(severityLabel)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(severityColor)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(Capsule().fill(severityColor.opacity(0.15)))
    }

    private var severityLabel: String {
        switch item.severity {
        case .low:      return "LOW"
        case .medium:   return "MEDIUM"
        case .high:     return "HIGH"
        case .critical: return "CRITICAL"
        }
    }
}
