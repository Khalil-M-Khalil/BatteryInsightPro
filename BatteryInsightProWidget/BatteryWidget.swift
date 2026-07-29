// BatteryWidget.swift
// Battery Insight Pro — WidgetKit Home Screen Widgets

import WidgetKit
import SwiftUI
import UIKit

// MARK: - Timeline Provider
struct BatteryWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(date: Date(), level: 0.82, health: 91, state: "Discharging", isLowPower: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> BatteryWidgetEntry {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Double(UIDevice.current.batteryLevel)
        let state: String
        switch UIDevice.current.batteryState {
        case .charging:  state = "Charging"
        case .full:      state = "Full"
        case .unplugged: state = "Discharging"
        default:         state = "Unknown"
        }
        let lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        // Health is estimated; can't read from widget without shared container
        let health: Double = UserDefaults(suiteName: "group.com.batteryinsightpro")?.double(forKey: "estimatedHealth") ?? 90
        return BatteryWidgetEntry(date: Date(), level: max(0, level), health: health, state: state, isLowPower: lowPower)
    }
}

struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let level: Double
    let health: Double
    let state: String
    let isLowPower: Bool
}

// MARK: - Widget Views
struct BatteryWidgetEntryView: View {
    var entry: BatteryWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        case .systemMedium: mediumView
        case .systemLarge:  largeView
        default:            smallView
        }
    }

    private var levelColor: Color {
        entry.level < 0.2 ? .red
        : entry.level < 0.4 ? .orange
        : entry.isLowPower ? .yellow
        : Color(hue: 0.38, saturation: 0.80, brightness: 0.85)
    }

    private var stateIcon: String {
        switch entry.state {
        case "Charging":    return "bolt.fill"
        case "Full":        return "battery.100.bolt"
        default:            return "battery.100"
        }
    }

    private var smallView: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.ultraThinMaterial)

            VStack(spacing: 6) {
                Image(systemName: stateIcon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(levelColor)

                Text("\(Int(entry.level * 100))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Battery")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                if entry.isLowPower {
                    Label("Low Power", systemImage: "bolt.slash")
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(.yellow)
                }
            }
            .padding(8)
        }
    }

    private var mediumView: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.ultraThinMaterial)

            HStack(spacing: 16) {
                // Left — Battery Level
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 8)
                            .frame(width: 70, height: 70)
                        Circle()
                            .trim(from: 0, to: entry.level)
                            .stroke(levelColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 70, height: 70)
                        Text("\(Int(entry.level * 100))%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    Text("Level")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Right — Info
                VStack(alignment: .leading, spacing: 6) {
                    Label(entry.state, systemImage: stateIcon)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(levelColor)

                    Label("Health: \(Int(entry.health))% (Est.)", systemImage: "heart.fill")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Label(entry.isLowPower ? "Low Power On" : "Normal Mode", systemImage: entry.isLowPower ? "bolt.slash" : "bolt")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(entry.isLowPower ? .yellow : .secondary)

                    Text(entry.date, style: .time)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(12)
        }
    }

    private var largeView: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.ultraThinMaterial)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "bolt.shield.fill")
                        .foregroundStyle(Color(hue: 0.58, saturation: 0.85, brightness: 0.95))
                    Text("Battery Insight Pro")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                // Large ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                        .frame(width: 110, height: 110)
                    Circle()
                        .trim(from: 0, to: entry.level)
                        .stroke(levelColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 110, height: 110)
                    VStack(spacing: 2) {
                        Text("\(Int(entry.level * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text(entry.state)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 20) {
                    widgetStat(value: "\(Int(entry.health))%", label: "Health (Est.)", color: Color(hue: 0.58, saturation: 0.85, brightness: 0.95))
                    widgetStat(value: entry.isLowPower ? "On" : "Off", label: "Low Power", color: .yellow)
                }
            }
            .padding(14)
        }
    }

    private func widgetStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Widget Configuration
@main
struct BatteryInsightProWidget: Widget {
    let kind = "BatteryInsightProWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryWidgetProvider()) { entry in
            BatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery Insight Pro")
        .description("Monitor your battery level, health, and charging status.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
