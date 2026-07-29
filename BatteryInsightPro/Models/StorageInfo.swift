// StorageInfo.swift
// Battery Insight Pro

import Foundation

struct StorageInfo {
    var totalBytes: Int64
    var usedBytes: Int64
    var freeBytes: Int64
    var cacheBytes: Int64      // estimated
    var systemBytes: Int64     // estimated
    var appBytes: Int64        // estimated
    var documentBytes: Int64   // estimated
    var photoBytes: Int64      // estimated
    var videoBytes: Int64      // estimated
    var downloadBytes: Int64   // estimated
    var tempBytes: Int64       // estimated
    var otherBytes: Int64      // estimated

    var usedPercent: Double { Double(usedBytes) / Double(max(totalBytes, 1)) * 100 }
    var freePercent: Double { 100.0 - usedPercent }

    var storageScore: Int {
        let freeP = freePercent
        if freeP > 40 { return 100 }
        if freeP > 25 { return 85 }
        if freeP > 15 { return 65 }
        if freeP > 5  { return 40 }
        return 15
    }

    var recommendations: [String] {
        var recs: [String] = []
        if freePercent < 10 { recs.append("⚠️ Storage is critically low. Delete unused apps and large files.") }
        if freePercent < 20 { recs.append("Clean up your Downloads and Trash folders.") }
        if cacheBytes > 500_000_000 { recs.append("Clear app caches to free up \(ByteFormatter.string(cacheBytes)).") }
        if tempBytes > 100_000_000 { recs.append("Temporary files are using \(ByteFormatter.string(tempBytes)). Restart apps to clear.") }
        if recommendations.isEmpty { recs.append("Storage health is good. No action needed.") }
        return recs
    }

    static func current() -> StorageInfo {
        let fm = FileManager.default
        var total: Int64 = 0
        var free: Int64 = 0
        if let attrs = try? fm.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            total = (attrs[.systemSize] as? Int64) ?? 0
            free  = (attrs[.systemFreeSize] as? Int64) ?? 0
        }
        let used = total - free
        // Estimate breakdown
        let system    = Int64(Double(used) * 0.08)
        let apps      = Int64(Double(used) * 0.25)
        let photos    = Int64(Double(used) * 0.20)
        let videos    = Int64(Double(used) * 0.18)
        let documents = Int64(Double(used) * 0.10)
        let cache     = Int64(Double(used) * 0.07)
        let downloads = Int64(Double(used) * 0.05)
        let temp      = Int64(Double(used) * 0.02)
        let other     = used - system - apps - photos - videos - documents - cache - downloads - temp
        return StorageInfo(
            totalBytes: total, usedBytes: used, freeBytes: free,
            cacheBytes: cache, systemBytes: system, appBytes: apps,
            documentBytes: documents, photoBytes: photos, videoBytes: videos,
            downloadBytes: downloads, tempBytes: temp, otherBytes: other
        )
    }
}

enum ByteFormatter {
    static func string(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
