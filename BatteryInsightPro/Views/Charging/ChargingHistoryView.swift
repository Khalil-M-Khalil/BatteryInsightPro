// ChargingHistoryView.swift
// Battery Insight Pro

import SwiftUI
import Charts

struct ChargingHistoryView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @State private var selectedPeriod = 0
    let periods = ["Week", "Month", "All"]

    var filteredSessions: [ChargingSession] {
        let now = Date()
        switch selectedPeriod {
        case 0: // Week
            let cutoff = now.addingTimeInterval(-7 * 24 * 3600)
            return batteryVM.sessions.filter { $0.startDate >= cutoff }
        case 1: // Month
            let cutoff = now.addingTimeInterval(-30 * 24 * 3600)
            return batteryVM.sessions.filter { $0.startDate >= cutoff }
        default:
            return batteryVM.sessions
        }
    }

    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(0..<periods.count, id: \.self) { i in
                            Text(periods[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if batteryVM.sessions.isEmpty {
                        emptyState
                    } else {
                        summaryCards
                        if !filteredSessions.isEmpty {
                            sessionsChart
                        }
                        sessionsList
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Charging History")
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                Image(systemName: "bolt.slash.circle")
                    .font(.system(size: 48)).foregroundStyle(Color.bip.accent)
                Text("No Charging Sessions Yet")
                    .font(BIPFont.headline())
                Text("Plug in your device to start tracking charging history.")
                    .font(BIPFont.body()).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }.padding(.vertical, BIPSpacing.lg)
        }.padding(.horizontal)
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BIPSpacing.sm) {
            QuickStatCard(title: "Total Sessions",    value: "\(filteredSessions.count)",                                   icon: "bolt.circle.fill",     gradient: Color.bip.accentGradient, availability: .live)
            QuickStatCard(title: "Avg Duration",      value: avgDuration,                                                    icon: "clock.fill",            gradient: Color.bip.warmGradient,   availability: .live)
            QuickStatCard(title: "Avg Efficiency",    value: String(format: "%.0f%%", avgEfficiency),                        icon: "bolt.badge.checkmark",  gradient: Color.bip.batteryGradient, availability: .estimated)
            QuickStatCard(title: "Avg Level Gained",  value: String(format: "+%.0f%%", avgLevelGained * 100),                icon: "arrow.up.circle.fill",  gradient: Color.bip.batteryGradient, availability: .live)
        }.padding(.horizontal)
    }

    private var avgDuration: String {
        guard !filteredSessions.isEmpty else { return "—" }
        let avg = filteredSessions.map { $0.duration }.reduce(0, +) / Double(filteredSessions.count)
        let h = Int(avg) / 3600
        let m = (Int(avg) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    private var avgEfficiency: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        return filteredSessions.map { $0.averageEfficiency }.reduce(0, +) / Double(filteredSessions.count)
    }

    private var avgLevelGained: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        return filteredSessions.map { $0.levelGained }.reduce(0, +) / Double(filteredSessions.count)
    }

    private var sessionsChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Level Gained Per Session", icon: "chart.bar.fill", iconColor: Color.bip.green)
                Chart {
                    ForEach(Array(filteredSessions.suffix(20).enumerated()), id: \.offset) { i, session in
                        BarMark(
                            x: .value("Session", i),
                            y: .value("Level", session.levelGained * 100)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: Color.bip.batteryGradient, startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(4)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine(stroke: StrokeStyle(dash: [3]))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel().font(BIPFont.caption()).foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 100)
            }
        }.padding(.horizontal)
    }

    private var sessionsList: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Sessions", icon: "list.bullet", iconColor: Color.bip.accent)
                ForEach(filteredSessions.reversed()) { session in
                    VStack(spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.startDate, style: .date)
                                    .font(BIPFont.body(weight: .semibold))
                                Text(session.startDate, style: .time)
                                    .font(BIPFont.caption()).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "+%.0f%%", session.levelGained * 100))
                                    .font(BIPFont.headline()).foregroundStyle(Color.bip.green)
                                Text(durationLabel(session.duration))
                                    .font(BIPFont.caption()).foregroundStyle(.secondary)
                            }
                        }
                        Divider().opacity(0.15)
                    }
                }
            }
        }.padding(.horizontal)
    }

    private func durationLabel(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600; let m = (Int(t) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}
