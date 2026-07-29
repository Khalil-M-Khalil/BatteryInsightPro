// DashboardView.swift
// Battery Insight Pro

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @EnvironmentObject var systemVM: SystemViewModel
    @EnvironmentObject var storageVM: StorageViewModel
    @EnvironmentObject var diagnosticsVM: DiagnosticsViewModel

    @State private var showScoreDetail = false
    @State private var headerPulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                BIPBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: BIPSpacing.lg) {
                        headerSection
                        batteryRingSection
                        quickStatsGrid
                        systemOverviewSection
                        healthScoreSection
                        recommendationsSection
                    }
                    .padding(.horizontal, BIPSpacing.md)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Battery Insight Pro")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { batteryVM.refresh(); systemVM.refresh() }
                    } label: {
                        Image(systemName: batteryVM.isRefreshing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                            .symbolEffect(.rotate, isActive: batteryVM.isRefreshing)
                            .foregroundStyle(Color.bip.accent)
                    }
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(systemVM.info.deviceName)
                    .font(BIPFont.headline())
                    .foregroundStyle(.secondary)
                Text(systemVM.info.deviceModel)
                    .font(BIPFont.caption())
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            StatusPill(
                text: batteryVM.info.state.rawValue,
                color: batteryVM.stateColor,
                icon: batteryVM.info.state.icon
            )
        }
        .padding(.top, BIPSpacing.sm)
    }

    // MARK: - Main Battery Ring
    private var batteryRingSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.lg) {
                HStack(spacing: BIPSpacing.xl) {
                    // Level ring
                    VStack(spacing: BIPSpacing.sm) {
                        CircularGauge(
                            value: batteryVM.info.level,
                            lineWidth: 14,
                            gradient: batteryVM.info.level < 0.2 ? Color.bip.dangerGradient : Color.bip.batteryGradient,
                            label: "Level",
                            valueText: batteryVM.levelPercent,
                            size: 150
                        )
                        Text("Battery Level")
                            .font(BIPFont.caption())
                            .foregroundStyle(.secondary)
                    }

                    // Health ring
                    VStack(spacing: BIPSpacing.sm) {
                        CircularGauge(
                            value: batteryVM.info.healthPercentage / 100.0,
                            lineWidth: 14,
                            gradient: Color.bip.accentGradient,
                            label: "Health",
                            valueText: batteryVM.healthPercent,
                            size: 150
                        )
                        Text("Battery Health")
                            .font(BIPFont.caption())
                            .foregroundStyle(.secondary)
                    }
                }

                // Condition badge
                HStack(spacing: BIPSpacing.sm) {
                    Image(systemName: batteryVM.info.condition.icon)
                        .foregroundStyle(Color(batteryVM.info.condition.color))
                    Text(batteryVM.info.condition.rawValue)
                        .font(BIPFont.headline())
                    Spacer()
                    Text(batteryVM.info.lifetimePrediction)
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BIPSpacing.sm) {
            QuickStatCard(
                title: "Screen Time",
                value: batteryVM.screenTimeLabel,
                icon: "iphone",
                gradient: Color.bip.accentGradient,
                availability: .estimated
            )
            QuickStatCard(
                title: "Standby",
                value: batteryVM.standbyTimeLabel,
                icon: "moon.fill",
                gradient: Color.bip.warmGradient,
                availability: .estimated
            )
            QuickStatCard(
                title: "Charge Efficiency",
                value: String(format: "%.0f%%", batteryVM.info.chargingEfficiency),
                icon: "bolt.circle.fill",
                gradient: Color.bip.batteryGradient,
                availability: .estimated
            )
            QuickStatCard(
                title: "Wear Level",
                value: String(format: "%.1f%%", batteryVM.info.wearLevel),
                icon: "battery.slash",
                gradient: batteryVM.info.wearLevel > 20 ? Color.bip.dangerGradient : Color.bip.batteryGradient,
                availability: .estimated
            )
        }
    }

    // MARK: - System Overview
    private var systemOverviewSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "System Overview", icon: "cpu", iconColor: Color.bip.purple)
                HStack(spacing: BIPSpacing.lg) {
                    MiniGauge(
                        value: systemVM.cpuPercent,
                        color: Color.bip.purple,
                        size: 70,
                        text: "\(Int(systemVM.info.cpuInfo.usagePercent))%"
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CPU").font(BIPFont.caption()).foregroundStyle(.secondary)
                        Text("\(Int(systemVM.info.cpuInfo.usagePercent))%").font(BIPFont.headline()).foregroundStyle(Color.bip.purple)
                    }
                    Spacer()
                    MiniGauge(
                        value: systemVM.ramPercent,
                        color: Color.bip.accent,
                        size: 70,
                        text: "\(Int(systemVM.ramPercent * 100))%"
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RAM").font(BIPFont.caption()).foregroundStyle(.secondary)
                        Text(systemVM.ramUsedLabel).font(BIPFont.headline()).foregroundStyle(Color.bip.accent)
                    }
                }
                Divider().opacity(0.2)
                HStack {
                    Label(systemVM.info.thermalState.displayName, systemImage: systemVM.info.thermalState.icon)
                        .font(BIPFont.caption())
                        .foregroundStyle(systemVM.thermalColor)
                    Spacer()
                    Label("Uptime: " + systemVM.uptimeLabel, systemImage: "clock")
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Health Score
    private var healthScoreSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "Device Health Score", icon: "heart.fill", iconColor: Color.bip.red)
                HStack(spacing: BIPSpacing.xl) {
                    ScoreRing(score: batteryVM.info.healthScore, title: "Battery", size: 100)
                    ScoreRing(score: systemVM.info.systemScore, title: "System", size: 100)
                    ScoreRing(score: storageVM.info.storageScore, title: "Storage", size: 100)
                }
            }
        }
    }

    // MARK: - Recommendations
    private var recommendationsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: BIPSpacing.sm) {
                SectionHeader(title: "Recommendations", icon: "lightbulb.fill", iconColor: Color.bip.yellow)
                ForEach(storageVM.info.recommendations, id: \.self) { rec in
                    HStack(alignment: .top, spacing: BIPSpacing.sm) {
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundStyle(Color.bip.accent)
                            .font(.system(size: 14))
                            .padding(.top, 2)
                        Text(rec)
                            .font(BIPFont.body())
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    var title: String
    var value: String
    var icon: String
    var gradient: [Color]
    var availability: MetricAvailability

    var body: some View {
        AccentCard(gradient: gradient) {
            VStack(alignment: .leading, spacing: BIPSpacing.xs) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(gradient.first ?? .white)
                    Spacer()
                    AvailabilityBadge(availability: availability)
                }
                Text(value)
                    .font(BIPFont.title2(weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(BIPFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }
}
