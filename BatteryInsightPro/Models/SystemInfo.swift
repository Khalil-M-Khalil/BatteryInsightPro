// SystemInfo.swift
// Battery Insight Pro

import Foundation
import UIKit

struct MemoryInfo {
    var total: UInt64          // bytes
    var used: UInt64           // bytes
    var free: UInt64           // bytes
    var wired: UInt64          // bytes
    var active: UInt64         // bytes
    var inactive: UInt64       // bytes
    var pressureLevel: String  // Normal / Warning / Critical
}

struct CPUInfo {
    var usagePercent: Double          // 0–100
    var processorCount: Int
    var activeProcessorCount: Int
    var userPercent: Double
    var systemPercent: Double
    var idlePercent: Double
}

struct SystemInfo {
    // LIVE
    var iOSVersion: String
    var buildNumber: String
    var deviceModel: String
    var modelIdentifier: String
    var deviceName: String
    var uptime: TimeInterval
    var processorCount: Int
    var activeProcessorCount: Int
    var physicalMemory: UInt64
    var thermalState: ProcessInfo.ThermalState
    var isLowPowerMode: Bool
    var kernelVersion: String

    // ESTIMATED
    var cpuInfo: CPUInfo
    var memoryInfo: MemoryInfo
    var systemScore: Int          // 0–100
    var backgroundProcessCount: Int // approximate
    var fileSystemHealth: String

    // UNAVAILABLE
    var gpuUsage: MetricValue<String>
    var diskActivity: MetricValue<String>

    static func current() -> SystemInfo {
        let processInfo = ProcessInfo.processInfo
        let device = UIDevice.current

        return SystemInfo(
            iOSVersion: processInfo.operatingSystemVersionString,
            buildNumber: getBuildNumber(),
            deviceModel: device.model,
            modelIdentifier: getModelIdentifier(),
            deviceName: device.name,
            uptime: processInfo.systemUptime,
            processorCount: processInfo.processorCount,
            activeProcessorCount: processInfo.activeProcessorCount,
            physicalMemory: processInfo.physicalMemory,
            thermalState: processInfo.thermalState,
            isLowPowerMode: processInfo.isLowPowerModeEnabled,
            kernelVersion: getKernelVersion(),
            cpuInfo: CPUInfo(usagePercent: 0, processorCount: processInfo.processorCount,
                             activeProcessorCount: processInfo.activeProcessorCount,
                             userPercent: 0, systemPercent: 0, idlePercent: 100),
            memoryInfo: MemoryInfo(total: processInfo.physicalMemory, used: 0, free: 0,
                                   wired: 0, active: 0, inactive: 0, pressureLevel: "Normal"),
            systemScore: 85,
            backgroundProcessCount: 12,
            fileSystemHealth: "Healthy",
            gpuUsage: MetricValue("Unavailable", availability: .unavailable,
                                  reason: "GPU usage requires private Metal Performance Shaders access"),
            diskActivity: MetricValue("Unavailable", availability: .unavailable,
                                      reason: "Disk I/O statistics require private kernel entitlements")
        )
    }

    private static func getBuildNumber() -> String {
        if let build = Bundle.main.infoDictionary?["DTSDKBuild"] as? String { return build }
        return ProcessInfo.processInfo.operatingSystemVersionString
    }

    private static func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    private static func getKernelVersion() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let release = withUnsafeBytes(of: systemInfo.release) { ptr in
            String(cString: ptr.bindMemory(to: CChar.self).baseAddress!)
        }
        return release
    }
}

extension ProcessInfo.ThermalState {
    var displayName: String {
        switch self {
        case .nominal:  return "Normal"
        case .fair:     return "Fair"
        case .serious:  return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
    var color: String {
        switch self {
        case .nominal:  return "green"
        case .fair:     return "yellow"
        case .serious:  return "orange"
        case .critical: return "red"
        @unknown default: return "gray"
        }
    }
    var icon: String {
        switch self {
        case .nominal:  return "thermometer.low"
        case .fair:     return "thermometer.medium"
        case .serious:  return "thermometer.high"
        case .critical: return "thermometer.sun.fill"
        @unknown default: return "thermometer"
        }
    }
}
