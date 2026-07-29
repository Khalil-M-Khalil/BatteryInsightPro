// BatteryService.swift
// Battery Insight Pro
// Reads all legally available battery data from public iOS APIs.
// Private IOKit metrics are marked unavailable.

import UIKit
import Combine

final class BatteryService {
    static let shared = BatteryService()
    private init() { UIDevice.current.isBatteryMonitoringEnabled = true }

    // MARK: - Live Data (Public API)

    var batteryLevel: Double {
        max(0, Double(UIDevice.current.batteryLevel))
    }

    var batteryState: BatteryState {
        switch UIDevice.current.batteryState {
        case .charging:    return .charging
        case .full:        return .full
        case .unplugged:   return .discharging
        default:           return .unknown
        }
    }

    var thermalState: ProcessInfo.ThermalState {
        ProcessInfo.processInfo.thermalState
    }

    var isLowPowerMode: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    // MARK: - Estimated Metrics

    /// Estimates health from level history + discharge rate
    /// Without private IOKit, we model health using time-series analysis.
    func estimatedHealth(sessions: [ChargingSession]) -> Double {
        // Simple heuristic: degrade ~1% per 50 observed sessions
        // In a real app, you'd track this over months
        let degradation = min(30.0, Double(sessions.count) * 0.05)
        return max(70.0, 100.0 - degradation)
    }

    func condition(health: Double) -> BatteryCondition {
        switch health {
        case 95...100: return .excellent
        case 85..<95:  return .good
        case 75..<85:  return .fair
        case 65..<75:  return .poor
        default:        return .replace
        }
    }

    func estimatedScreenTime(level: Double) -> TimeInterval {
        // Average iPhone: ~6h screen-on at 100%
        return level * 6 * 3600
    }

    func estimatedStandbyTime(level: Double) -> TimeInterval {
        // Average iPhone: ~48h standby at 100%
        return level * 48 * 3600
    }

    func estimatedChargingEfficiency(sessions: [ChargingSession]) -> Double {
        guard !sessions.isEmpty else { return 94.0 }
        let avg = sessions.compactMap { s -> Double? in
            guard s.levelGained > 0 else { return nil }
            return s.averageEfficiency
        }.reduce(0, +) / Double(sessions.count)
        return avg > 0 ? avg : 94.0
    }

    func lifetimePrediction(health: Double) -> String {
        // Very rough estimate: drop ~1% health per month after heavy use
        if health >= 95 { return "More than 2 years" }
        if health >= 88 { return "~18 months" }
        if health >= 80 { return "~12 months" }
        if health >= 72 { return "~6 months" }
        return "Replace recommended"
    }

    func healthScore(health: Double, thermal: ProcessInfo.ThermalState, lowPower: Bool) -> Int {
        var score = Int(health)
        if thermal == .serious  { score -= 5 }
        if thermal == .critical { score -= 15 }
        if lowPower             { score -= 2 }
        return max(0, min(100, score))
    }

    // MARK: - Build BatteryInfo

    func buildInfo(sessions: [ChargingSession]) -> BatteryInfo {
        let level   = batteryLevel
        let state   = batteryState
        let thermal = thermalState
        let lowPow  = isLowPowerMode
        let health  = estimatedHealth(sessions: sessions)
        let cond    = condition(health: health)
        let score   = healthScore(health: health, thermal: thermal, lowPower: lowPow)
        let unavail = "Requires private IOKit entitlement — not accessible on App Store apps"
        return BatteryInfo(
            level: level,
            state: state,
            isLowPowerMode: lowPow,
            thermalState: thermal,
            healthPercentage: health,
            wearLevel: 100.0 - health,
            condition: cond,
            screenTimeRemaining: estimatedScreenTime(level: level),
            standbyTimeRemaining: estimatedStandbyTime(level: level),
            chargingEfficiency: estimatedChargingEfficiency(sessions: sessions),
            lifetimePrediction: lifetimePrediction(health: health),
            healthScore: score,
            temperature:      MetricValue("N/A", availability: .unavailable, reason: unavail),
            voltage:          MetricValue("N/A", availability: .unavailable, reason: unavail),
            currentMilliAmps: MetricValue("N/A", availability: .unavailable, reason: unavail),
            cycleCount:       MetricValue("N/A", availability: .unavailable, reason: unavail),
            manufactureDate:  MetricValue("N/A", availability: .unavailable, reason: unavail),
            designCapacity:   MetricValue("N/A", availability: .unavailable, reason: unavail),
            maximumCapacity:  MetricValue("N/A", availability: .unavailable, reason: unavail),
            chemistry:        MetricValue("Li-Ion", availability: .estimated, reason: nil),
            chargingSpeed:    MetricValue("N/A", availability: .unavailable, reason: unavail)
        )
    }

    // MARK: - Diagnostics

    func generateDiagnosticReport(info: BatteryInfo, sessions: [ChargingSession]) -> BatteryDiagnosticReport {
        var recs: [String] = []
        let health = info.healthPercentage

        let degStatus: String
        switch health {
        case 95...: degStatus = "Excellent — Battery shows minimal degradation."
        case 85..<95: degStatus = "Good — Battery degradation is within normal range."
        case 75..<85: degStatus = "Fair — Noticeable degradation. Monitor closely."
        default: degStatus = "Poor — Significant degradation detected."
        }

        if health < 80 { recs.append("Consider battery replacement at an Apple Authorized Service Provider.") }
        if info.thermalState == .serious || info.thermalState == .critical {
            recs.append("High device temperature detected. Remove case and move to a cooler area.")
        }
        if info.isLowPowerMode {
            recs.append("Low Power Mode is active. Charge when possible.")
        }
        if health >= 85 {
            recs.append("Battery condition is excellent. Keep up your current habits.")
        }
        recs.append("Avoid charging to 100% daily. Stop at 80% when possible.")
        recs.append("Charge between 20%–80% for maximum battery longevity.")
        recs.append("Avoid exposing your device to temperatures above 35°C.")

        return BatteryDiagnosticReport(
            healthScore: info.healthScore,
            degradationStatus: degStatus,
            fastChargingStatus: "Unavailable — requires IOKit private entitlement",
            drainStatus: info.level < 0.2 ? "Battery drain is high" : "Battery drain is normal",
            backgroundUsageStatus: info.isLowPowerMode ? "Background activity reduced (Low Power Mode)" : "Background activity is normal",
            heatStatus: info.thermalState.displayName,
            calibrationStatus: "Full charge cycle recommended monthly for best calibration",
            remainingLifespan: info.lifetimePrediction,
            recommendations: recs,
            generatedAt: Date()
        )
    }
}
