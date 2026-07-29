// HardwareDiagnostic.swift
// Battery Insight Pro

import Foundation

enum DiagnosticResult {
    case pass
    case warning(String)
    case failed(String)
    case unavailable(String)
    case running

    var icon: String {
        switch self {
        case .pass:        return "checkmark.circle.fill"
        case .warning:     return "exclamationmark.triangle.fill"
        case .failed:      return "xmark.circle.fill"
        case .unavailable: return "slash.circle"
        case .running:     return "arrow.triangle.2.circlepath"
        }
    }

    var colorName: String {
        switch self {
        case .pass:        return "green"
        case .warning:     return "yellow"
        case .failed:      return "red"
        case .unavailable: return "gray"
        case .running:     return "blue"
        }
    }

    var label: String {
        switch self {
        case .pass:             return "Pass"
        case .warning(let m):   return "Warning: \(m)"
        case .failed(let m):    return "Failed: \(m)"
        case .unavailable(let m): return "N/A: \(m)"
        case .running:          return "Testing…"
        }
    }

    var shortLabel: String {
        switch self {
        case .pass:        return "Pass"
        case .warning:     return "Warning"
        case .failed:      return "Failed"
        case .unavailable: return "N/A"
        case .running:     return "Testing"
        }
    }
}

struct HardwareDiagnosticItem: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var result: DiagnosticResult
    var detail: String
}

struct HardwareDiagnosticsReport {
    var items: [HardwareDiagnosticItem]
    var overallScore: Int
    var generatedAt: Date

    var passCount: Int    { items.filter { if case .pass = $0.result { return true }; return false }.count }
    var warningCount: Int { items.filter { if case .warning = $0.result { return true }; return false }.count }
    var failCount: Int    { items.filter { if case .failed = $0.result { return true }; return false }.count }
}

struct ChargingSession: Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var startLevel: Double
    var endLevel: Double
    var peakLevel: Double
    var duration: TimeInterval { (endDate ?? Date()).timeIntervalSince(startDate) }
    var levelGained: Double { endLevel - startLevel }
    var averageEfficiency: Double // estimated %
    var chargingSpeedLabel: String // e.g. "Standard" / "Fast" (estimated)
}

struct DeviceHealthScore {
    var batteryScore: Int
    var performanceScore: Int
    var storageScore: Int
    var systemScore: Int
    var securityScore: Int
    var overall: Int

    static func compute(battery: Int, perf: Int, storage: Int, system: Int) -> DeviceHealthScore {
        let sec = 90 // No public API for security state; use a high default
        let overall = (battery * 35 + perf * 25 + storage * 20 + system * 15 + sec * 5) / 100
        return DeviceHealthScore(
            batteryScore: battery,
            performanceScore: perf,
            storageScore: storage,
            systemScore: system,
            securityScore: sec,
            overall: overall
        )
    }
}

struct ErrorItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var severity: Severity
    var icon: String
    var recommendation: String

    enum Severity { case low, medium, high, critical }
}
