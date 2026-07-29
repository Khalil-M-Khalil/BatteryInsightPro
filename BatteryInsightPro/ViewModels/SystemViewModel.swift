// SystemViewModel.swift
// Battery Insight Pro

import SwiftUI
import Combine

final class SystemViewModel: ObservableObject {
    @Published var info: SystemInfo = SystemInfo.current()
    @Published var isRefreshing = false

    private var timer: AnyCancellable?
    private let service = SystemService.shared

    init() {
        refresh()
        startTimer()
    }

    func refresh() {
        isRefreshing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let newInfo = self.service.currentInfo()
            DispatchQueue.main.async {
                self.info = newInfo
                self.isRefreshing = false
            }
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                DispatchQueue.global(qos: .background).async {
                    let newInfo = self.service.currentInfo()
                    DispatchQueue.main.async { self.info = newInfo }
                }
            }
    }

    // MARK: - Formatted Properties
    var uptimeLabel: String {
        let seconds = Int(info.uptime)
        let days    = seconds / 86400
        let hours   = (seconds % 86400) / 3600
        let mins    = (seconds % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h \(mins)m" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }

    var ramUsedLabel: String {
        let used = info.memoryInfo.used
        return ByteFormatter.string(Int64(used))
    }

    var ramTotalLabel: String {
        ByteFormatter.string(Int64(info.physicalMemory))
    }

    var ramPercent: Double {
        guard info.physicalMemory > 0 else { return 0 }
        return Double(info.memoryInfo.used) / Double(info.physicalMemory)
    }

    var cpuPercent: Double {
        min(info.cpuInfo.usagePercent / 100.0, 1.0)
    }

    var cpuGradient: [Color] {
        let p = info.cpuInfo.usagePercent
        if p < 50 { return [Color.bip.green, Color.bip.mint] }
        if p < 80 { return [Color.bip.yellow, Color.bip.orange] }
        return [Color.bip.red, Color.bip.orange]
    }

    var ramGradient: [Color] {
        let p = ramPercent
        if p < 0.70 { return [Color.bip.accent, Color.bip.purple] }
        if p < 0.85 { return [Color.bip.yellow, Color.bip.orange] }
        return [Color.bip.red, Color.bip.orange]
    }

    var thermalColor: Color {
        switch info.thermalState {
        case .nominal:  return Color.bip.green
        case .fair:     return Color.bip.yellow
        case .serious:  return Color.bip.orange
        case .critical: return Color.bip.red
        @unknown default: return Color.gray
        }
    }

    var deviceErrors: [ErrorItem] {
        var errors: [ErrorItem] = []
        if info.cpuInfo.usagePercent > 80 {
            errors.append(ErrorItem(
                title: "High CPU Usage",
                description: "CPU usage is at \(Int(info.cpuInfo.usagePercent))%. This may indicate background processes consuming excessive resources.",
                severity: .high,
                icon: "cpu",
                recommendation: "Close unused apps and check for background processes."
            ))
        }
        if ramPercent > 0.85 {
            errors.append(ErrorItem(
                title: "Memory Pressure",
                description: "RAM usage is above 85%. Apps may start crashing or reloading.",
                severity: .medium,
                icon: "memorychip",
                recommendation: "Restart apps or reboot your device to free memory."
            ))
        }
        if info.thermalState == .serious || info.thermalState == .critical {
            errors.append(ErrorItem(
                title: "Thermal Throttling",
                description: "Your device is running hot (\(info.thermalState.displayName)). Performance is being reduced automatically.",
                severity: .critical,
                icon: "thermometer.sun.fill",
                recommendation: "Remove the case, stop charging, and move to a cooler environment."
            ))
        }
        if info.isLowPowerMode {
            errors.append(ErrorItem(
                title: "Low Power Mode Active",
                description: "Performance is reduced to conserve battery.",
                severity: .low,
                icon: "battery.25",
                recommendation: "Charge your device to disable Low Power Mode."
            ))
        }
        return errors
    }
}
