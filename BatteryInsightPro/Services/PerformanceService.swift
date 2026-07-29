// PerformanceService.swift
// Battery Insight Pro — real-time 1-second performance sampling

import Foundation
import Combine
import Darwin

final class PerformanceService {
    static let shared = PerformanceService()
    private init() {}

    struct Sample {
        var timestamp: Date
        var cpuPercent: Double
        var memUsedBytes: UInt64
        var batteryLevel: Double
        var thermalState: ProcessInfo.ThermalState
    }

    private(set) var samples: [Sample] = []
    private let maxSamples = 120   // 2 minutes of history

    func takeSample() -> Sample {
        let cpu = SystemService.shared.cpuUsage()
        let mem = SystemService.shared.memoryInfo()
        let s = Sample(
            timestamp: Date(),
            cpuPercent: cpu.usagePercent,
            memUsedBytes: mem.used,
            batteryLevel: BatteryService.shared.batteryLevel,
            thermalState: ProcessInfo.processInfo.thermalState
        )
        samples.append(s)
        if samples.count > maxSamples { samples.removeFirst() }
        return s
    }

    func cpuHistory() -> [Double] { samples.map { $0.cpuPercent } }
    func memHistory() -> [UInt64] { samples.map { $0.memUsedBytes } }
    func batteryHistory() -> [Double] { samples.map { $0.batteryLevel * 100 } }
}
