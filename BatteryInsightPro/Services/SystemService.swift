// SystemService.swift
// Battery Insight Pro

import Foundation
import UIKit
import Darwin

final class SystemService {
    static let shared = SystemService()
    private init() {}

    func cpuUsage() -> CPUInfo {
        var cpuLoad = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return CPUInfo(usagePercent: 0, processorCount: ProcessInfo.processInfo.processorCount,
                           activeProcessorCount: ProcessInfo.processInfo.activeProcessorCount,
                           userPercent: 0, systemPercent: 0, idlePercent: 100)
        }
        let user   = Double(cpuLoad.cpu_ticks.0)
        let system = Double(cpuLoad.cpu_ticks.1)
        let idle   = Double(cpuLoad.cpu_ticks.2)
        let nice   = Double(cpuLoad.cpu_ticks.3)
        let total  = user + system + idle + nice
        guard total > 0 else {
            return CPUInfo(usagePercent: 0, processorCount: ProcessInfo.processInfo.processorCount,
                           activeProcessorCount: ProcessInfo.processInfo.activeProcessorCount,
                           userPercent: 0, systemPercent: 0, idlePercent: 100)
        }
        let userP   = user   / total * 100
        let systemP = system / total * 100
        let idleP   = idle   / total * 100
        let usedP   = userP + systemP + (nice / total * 100)
        return CPUInfo(
            usagePercent: usedP,
            processorCount: ProcessInfo.processInfo.processorCount,
            activeProcessorCount: ProcessInfo.processInfo.activeProcessorCount,
            userPercent: userP,
            systemPercent: systemP,
            idlePercent: idleP
        )
    }

    func memoryInfo() -> MemoryInfo {
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        let pageSize = UInt64(vm_page_size)
        let total    = ProcessInfo.processInfo.physicalMemory
        var used: UInt64 = 0
        var free: UInt64 = 0
        var wired: UInt64 = 0
        var active: UInt64 = 0
        var inactive: UInt64 = 0
        if result == KERN_SUCCESS {
            active   = UInt64(stats.active_count)   * pageSize
            inactive = UInt64(stats.inactive_count) * pageSize
            wired    = UInt64(stats.wire_count)      * pageSize
            free     = UInt64(stats.free_count)      * pageSize
            used     = total - free
        }
        let pressure = memoryPressureLevel()
        return MemoryInfo(total: total, used: used, free: free,
                          wired: wired, active: active, inactive: inactive,
                          pressureLevel: pressure)
    }

    private func memoryPressureLevel() -> String {
        var mem = MemoryInfo(total: 0, used: 0, free: 0, wired: 0, active: 0, inactive: 0, pressureLevel: "")
        let total = ProcessInfo.processInfo.physicalMemory
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return "Normal" }
        let free = UInt64(stats.free_count) * UInt64(vm_page_size)
        let freePercent = Double(free) / Double(max(total, 1)) * 100
        if freePercent < 5  { return "Critical" }
        if freePercent < 15 { return "Warning" }
        return "Normal"
    }

    func systemScore(cpu: CPUInfo, mem: MemoryInfo, thermal: ProcessInfo.ThermalState) -> Int {
        var score = 100
        if cpu.usagePercent > 80  { score -= 20 }
        else if cpu.usagePercent > 50 { score -= 10 }
        let usedMemPercent = Double(mem.used) / Double(max(mem.total, 1)) * 100
        if usedMemPercent > 90 { score -= 20 }
        else if usedMemPercent > 75 { score -= 10 }
        switch thermal {
        case .critical: score -= 25
        case .serious:  score -= 15
        case .fair:     score -= 5
        default: break
        }
        return max(0, min(100, score))
    }

    func currentInfo() -> SystemInfo {
        let cpu = cpuUsage()
        let mem = memoryInfo()
        let thermal = ProcessInfo.processInfo.thermalState
        let score = systemScore(cpu: cpu, mem: mem, thermal: thermal)
        var info = SystemInfo.current()
        info.cpuInfo = cpu
        info.memoryInfo = mem
        info.systemScore = score
        return info
    }
}
