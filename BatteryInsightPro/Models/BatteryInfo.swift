// BatteryInfo.swift
// Battery Insight Pro

import Foundation
import UIKit

/// Availability of a metric on a stock iOS device
enum MetricAvailability {
    case live        // 🟢 Available via public API
    case estimated   // 🟡 Derived / calculated
    case unavailable // 🔴 Private API – cannot be accessed on non-jailbroken device
}

struct MetricValue<T> {
    let value: T
    let availability: MetricAvailability
    let unavailableReason: String?

    init(_ value: T, availability: MetricAvailability, reason: String? = nil) {
        self.value = value
        self.availability = availability
        self.unavailableReason = reason
    }
}

enum BatteryState: String {
    case charging    = "Charging"
    case discharging = "Discharging"
    case full        = "Full"
    case unknown     = "Unknown"

    var icon: String {
        switch self {
        case .charging:    return "bolt.fill"
        case .discharging: return "battery.100"
        case .full:        return "battery.100.bolt"
        case .unknown:     return "questionmark.circle"
        }
    }

    var color: String {
        switch self {
        case .charging:    return "green"
        case .discharging: return "orange"
        case .full:        return "blue"
        case .unknown:     return "gray"
        }
    }
}

enum BatteryCondition: String {
    case excellent  = "Excellent"
    case good       = "Good"
    case fair       = "Fair"
    case poor       = "Poor"
    case replace    = "Replace Soon"

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good:      return "mint"
        case .fair:      return "yellow"
        case .poor:      return "orange"
        case .replace:   return "red"
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "checkmark.seal.fill"
        case .good:      return "checkmark.circle.fill"
        case .fair:      return "exclamationmark.circle"
        case .poor:      return "exclamationmark.triangle.fill"
        case .replace:   return "xmark.circle.fill"
        }
    }
}

struct BatteryInfo {
    // LIVE metrics
    var level: Double                     // 0.0–1.0
    var state: BatteryState
    var isLowPowerMode: Bool
    var thermalState: ProcessInfo.ThermalState

    // ESTIMATED metrics
    var healthPercentage: Double          // estimated from degradation model
    var wearLevel: Double                 // 1.0 - healthPercentage
    var condition: BatteryCondition
    var screenTimeRemaining: TimeInterval // estimated
    var standbyTimeRemaining: TimeInterval
    var chargingEfficiency: Double        // estimated %
    var lifetimePrediction: String        // e.g. "~18 months"
    var healthScore: Int                  // 0–100 composite score

    // UNAVAILABLE on stock iOS
    var temperature: MetricValue<String>  // requires private IOKit
    var voltage: MetricValue<String>      // requires private IOKit
    var currentMilliAmps: MetricValue<String>
    var cycleCount: MetricValue<String>
    var manufactureDate: MetricValue<String>
    var designCapacity: MetricValue<String>   // mAh
    var maximumCapacity: MetricValue<String>  // mAh
    var chemistry: MetricValue<String>
    var chargingSpeed: MetricValue<String>

    static func placeholder() -> BatteryInfo {
        let unavailable = "Requires private IOKit entitlement (unavailable on App Store apps)"
        return BatteryInfo(
            level: 0.82,
            state: .discharging,
            isLowPowerMode: false,
            thermalState: .nominal,
            healthPercentage: 91.0,
            wearLevel: 9.0,
            condition: .excellent,
            screenTimeRemaining: 14400,
            standbyTimeRemaining: 86400,
            chargingEfficiency: 94.0,
            lifetimePrediction: "~18 months",
            healthScore: 91,
            temperature: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            voltage: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            currentMilliAmps: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            cycleCount: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            manufactureDate: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            designCapacity: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            maximumCapacity: MetricValue("Unavailable", availability: .unavailable, reason: unavailable),
            chemistry: MetricValue("Li-Ion (Standard)", availability: .estimated, reason: nil),
            chargingSpeed: MetricValue("Unavailable", availability: .unavailable, reason: unavailable)
        )
    }
}

struct BatteryDiagnosticReport {
    var healthScore: Int
    var degradationStatus: String
    var fastChargingStatus: String
    var drainStatus: String
    var backgroundUsageStatus: String
    var heatStatus: String
    var calibrationStatus: String
    var remainingLifespan: String
    var recommendations: [String]
    var generatedAt: Date
}
