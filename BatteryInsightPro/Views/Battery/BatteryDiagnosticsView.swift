// BatteryDiagnosticsView.swift
// Battery Insight Pro

import SwiftUI

struct BatteryDiagnosticsView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @State private var hasRun = false

    var body: some View {
        VStack(spacing: BIPSpacing.lg) {
            if !hasRun {
                GlassCard {
                    VStack(spacing: BIPSpacing.md) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.bip.accent)
                        Text("Battery Diagnostics")
                            .font(BIPFont.title2())
                        Text("Run a complete analysis of your battery's health, charging habits, and performance.")
                            .font(BIPFont.body())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button {
                            batteryVM.runDiagnostics()
                            withAnimation { hasRun = true }
                        } label: {
                            Label("Run Diagnostics", systemImage: "play.fill")
                                .font(BIPFont.headline())
                                .foregroundStyle(.white)
                                .padding(.horizontal, BIPSpacing.lg)
                                .padding(.vertical, BIPSpacing.sm)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(colors: Color.bip.accentGradient, startPoint: .leading, endPoint: .trailing))
                                )
                        }
                    }
                    .padding(.vertical, BIPSpacing.lg)
                }
                .padding(.horizontal)
            } else if let report = batteryVM.diagnosticReport {
                reportContent(report)
            }
        }
    }

    private func reportContent(_ report: BatteryDiagnosticReport) -> some View {
        VStack(spacing: BIPSpacing.md) {
            // Health Score
            GlassCard {
                HStack(spacing: BIPSpacing.lg) {
                    ScoreRing(score: report.healthScore, title: "Health Score", size: 120)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Battery Score")
                            .font(BIPFont.headline())
                        Text(report.degradationStatus)
                            .font(BIPFont.body())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(report.remainingLifespan)
                            .font(BIPFont.caption())
                            .foregroundStyle(Color.bip.accent)
                    }
                }
            }.padding(.horizontal)

            // Diagnostic rows
            GlassCard {
                VStack(spacing: BIPSpacing.sm) {
                    SectionHeader(title: "Analysis", icon: "list.bullet.clipboard", iconColor: Color.bip.accent)
                    diagRow(icon: "gauge.badge.minus",   title: "Degradation",          text: report.degradationStatus)
                    Divider().opacity(0.2)
                    diagRow(icon: "bolt.fill",           title: "Fast Charging",         text: report.fastChargingStatus)
                    Divider().opacity(0.2)
                    diagRow(icon: "arrow.down.right.circle", title: "Drain Status",      text: report.drainStatus)
                    Divider().opacity(0.2)
                    diagRow(icon: "apps.iphone",         title: "Background Usage",      text: report.backgroundUsageStatus)
                    Divider().opacity(0.2)
                    diagRow(icon: "thermometer",         title: "Heat Generation",       text: report.heatStatus)
                    Divider().opacity(0.2)
                    diagRow(icon: "dial.medium",         title: "Calibration",           text: report.calibrationStatus)
                }
            }.padding(.horizontal)

            // Recommendations
            GlassCard {
                VStack(alignment: .leading, spacing: BIPSpacing.sm) {
                    SectionHeader(title: "Recommendations", icon: "lightbulb.fill", iconColor: Color.bip.yellow)
                    ForEach(report.recommendations, id: \.self) { rec in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.bip.green)
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            Text(rec)
                                .font(BIPFont.body())
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }.padding(.horizontal)

            Button {
                batteryVM.runDiagnostics()
            } label: {
                Label("Re-run Diagnostics", systemImage: "arrow.clockwise")
                    .font(BIPFont.body(weight: .semibold))
                    .foregroundStyle(Color.bip.accent)
            }
            .padding(.bottom, 20)
        }
    }

    private func diagRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: BIPSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.bip.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BIPFont.body(weight: .semibold))
                Text(text)
                    .font(BIPFont.caption())
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}
