// PDFReportService.swift
// Battery Insight Pro — Generates professional PDF reports using PDFKit

import Foundation
import PDFKit
import UIKit

final class PDFReportService {
    static let shared = PDFReportService()
    private init() {}

    func generate(battery: BatteryInfo, system: SystemInfo, storage: StorageInfo, reportType: String) async -> URL? {
        return await Task.detached(priority: .userInitiated) {
            self.buildPDF(battery: battery, system: system, storage: storage, reportType: reportType)
        }.value
    }

    private func buildPDF(battery: BatteryInfo, system: SystemInfo, storage: StorageInfo, reportType: String) -> URL? {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: Date())

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let page = ctx.pdfContextBounds

            // Background
            UIColor(red: 0.05, green: 0.05, blue: 0.10, alpha: 1).setFill()
            UIRectFill(page)

            // Header gradient bar
            let headerRect = CGRect(x: 0, y: 0, width: page.width, height: 80)
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor] as CFArray,
                                      locations: [0, 1])!
            let context = UIGraphicsGetCurrentContext()!
            context.saveGState()
            context.addRect(headerRect)
            context.clip()
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: 0),
                                       end: CGPoint(x: page.width, y: 0),
                                       options: [])
            context.restoreGState()

            // Title
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let title = NSAttributedString(string: "Battery Insight Pro", attributes: titleAttr)
            title.draw(at: CGPoint(x: 30, y: 20))

            let subtitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let subtitle = NSAttributedString(string: "\(reportType) — \(dateString)", attributes: subtitleAttr)
            subtitle.draw(at: CGPoint(x: 30, y: 52))

            // Device info
            var yOffset: CGFloat = 110

            yOffset = drawSection(context: context, title: "Device Information", y: yOffset, width: page.width, rows: [
                ("Device", system.deviceModel),
                ("iOS Version", system.iOSVersion),
                ("Model Identifier", system.modelIdentifier),
                ("Kernel Version", system.kernelVersion),
            ])

            yOffset += 10
            yOffset = drawSection(context: context, title: "Battery Status", y: yOffset, width: page.width, rows: [
                ("Battery Level", "\(Int(battery.level * 100))% (🟢 Live)"),
                ("Charging State", "\(battery.state.rawValue) (🟢 Live)"),
                ("Low Power Mode", battery.isLowPowerMode ? "Active" : "Off"),
                ("Thermal State", battery.thermalState.displayName),
                ("Health", "\(Int(battery.healthPercentage))% (🟡 Estimated)"),
                ("Wear Level", String(format: "%.1f%% (🟡 Estimated)", battery.wearLevel)),
                ("Condition", battery.condition.rawValue),
                ("Charge Efficiency", String(format: "%.0f%% (🟡 Estimated)", battery.chargingEfficiency)),
                ("Lifetime Prediction", "\(battery.lifetimePrediction) (🟡 Estimated)"),
                ("Battery Chemistry", "\(battery.chemistry.value) (🟡 Estimated)"),
                ("Temperature", "🔴 Unavailable (private API)"),
                ("Voltage", "🔴 Unavailable (private API)"),
                ("Cycle Count", "🔴 Unavailable (private API)"),
                ("Design Capacity", "🔴 Unavailable (private API)"),
            ])

            yOffset += 10
            yOffset = drawSection(context: context, title: "System", y: yOffset, width: page.width, rows: [
                ("CPU Usage", String(format: "%.1f%%", system.cpuInfo.usagePercent)),
                ("RAM Used", ByteFormatter.string(Int64(system.memoryInfo.used))),
                ("RAM Total", ByteFormatter.string(Int64(system.physicalMemory))),
                ("Memory Pressure", system.memoryInfo.pressureLevel),
                ("Uptime", formatUptime(system.uptime)),
            ])

            yOffset += 10
            yOffset = drawSection(context: context, title: "Storage", y: yOffset, width: page.width, rows: [
                ("Total", ByteFormatter.string(storage.totalBytes)),
                ("Used", ByteFormatter.string(storage.usedBytes)),
                ("Free", ByteFormatter.string(storage.freeBytes)),
                ("Usage", String(format: "%.0f%%", storage.usedPercent)),
            ])

            // Footer
            let footerAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let footer = NSAttributedString(
                string: "Battery Insight Pro • Generated \(dateString) • Metrics labeled Live/Estimated/Unavailable per API availability",
                attributes: footerAttr
            )
            footer.draw(at: CGPoint(x: 30, y: page.height - 30))
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("BatteryInsightPro_Report_\(Int(Date().timeIntervalSince1970)).pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("PDF write error: \(error)")
            return nil
        }
    }

    @discardableResult
    private func drawSection(context: CGContext, title: String, y: CGFloat, width: CGFloat, rows: [(String, String)]) -> CGFloat {
        var yOffset = y

        // Section title
        let sectionAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.systemBlue
        ]
        NSAttributedString(string: title, attributes: sectionAttr).draw(at: CGPoint(x: 30, y: yOffset))
        yOffset += 22

        // Divider
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.1).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 30, y: yOffset))
        context.addLine(to: CGPoint(x: width - 30, y: yOffset))
        context.strokePath()
        yOffset += 8

        let labelAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
        let valueAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]

        for (label, value) in rows {
            NSAttributedString(string: label, attributes: labelAttr).draw(at: CGPoint(x: 30, y: yOffset))
            NSAttributedString(string: value, attributes: valueAttr).draw(at: CGPoint(x: 220, y: yOffset))
            yOffset += 18
        }

        return yOffset
    }

    private func formatUptime(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        let d = s / 86400; let h = (s % 86400) / 3600; let m = (s % 3600) / 60
        return d > 0 ? "\(d)d \(h)h \(m)m" : "\(h)h \(m)m"
    }
}
