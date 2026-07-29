// PerformanceViewModel.swift
// Battery Insight Pro

import SwiftUI
import Combine

final class PerformanceViewModel: ObservableObject {
    @Published var currentCPU: Double = 0
    @Published var currentRAMUsed: UInt64 = 0
    @Published var currentRAMTotal: UInt64 = 0
    @Published var batteryLevel: Double = 0
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    @Published var cpuHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var ramHistory: [Double] = Array(repeating: 0, count: 60)
    @Published var batteryHistory: [Double] = Array(repeating: 100, count: 60)

    private var timer: AnyCancellable?
    private let service = PerformanceService.shared

    init() {
        startSampling()
    }

    private func startSampling() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let sample = self.service.takeSample()

                self.currentCPU        = sample.cpuPercent
                self.currentRAMUsed    = sample.memUsedBytes
                self.currentRAMTotal   = ProcessInfo.processInfo.physicalMemory
                self.batteryLevel      = sample.batteryLevel * 100
                self.thermalState      = sample.thermalState

                self.cpuHistory.append(sample.cpuPercent)
                if self.cpuHistory.count > 60 { self.cpuHistory.removeFirst() }

                let ramPct = Double(sample.memUsedBytes) / Double(max(ProcessInfo.processInfo.physicalMemory, 1)) * 100
                self.ramHistory.append(ramPct)
                if self.ramHistory.count > 60 { self.ramHistory.removeFirst() }

                self.batteryHistory.append(sample.batteryLevel * 100)
                if self.batteryHistory.count > 60 { self.batteryHistory.removeFirst() }
            }
    }

    var ramPercent: Double {
        guard currentRAMTotal > 0 else { return 0 }
        return Double(currentRAMUsed) / Double(currentRAMTotal) * 100
    }

    var ramUsedLabel: String { ByteFormatter.string(Int64(currentRAMUsed)) }
    var ramTotalLabel: String { ByteFormatter.string(Int64(currentRAMTotal)) }

    var thermalColor: Color {
        switch thermalState {
        case .nominal:  return Color.bip.green
        case .fair:     return Color.bip.yellow
        case .serious:  return Color.bip.orange
        case .critical: return Color.bip.red
        @unknown default: return Color.gray
        }
    }

    var cpuGradient: [Color] {
        if currentCPU < 50 { return [Color.bip.green, Color.bip.mint] }
        if currentCPU < 80 { return [Color.bip.yellow, Color.bip.orange] }
        return [Color.bip.red, Color.bip.orange]
    }
}
