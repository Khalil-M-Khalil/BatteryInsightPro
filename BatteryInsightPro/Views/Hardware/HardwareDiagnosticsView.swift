// HardwareDiagnosticsView.swift
// Battery Insight Pro

import SwiftUI

struct HardwareDiagnosticsView: View {
    @EnvironmentObject var diagnosticsVM: DiagnosticsViewModel
    @State private var didStart = false

    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    if !didStart {
                        startCard
                    } else {
                        progressSection
                        itemsSection
                        if let report = diagnosticsVM.report, !diagnosticsVM.isRunning {
                            summarySection(report)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Hardware Diagnostics")
        .navigationBarTitleDisplayMode(.large)
    }

    private var startCard: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                Image(systemName: "stethoscope").font(.system(size: 52)).foregroundStyle(Color.bip.accent)
                Text("Hardware Diagnostics")
                    .font(BIPFont.title2())
                Text("Test your device sensors, cameras, motion hardware, and connectivity modules.")
                    .font(BIPFont.body()).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Text("Note: Some hardware tests (proximity sensor, ambient light sensor) require private entitlements and will show as N/A.")
                    .font(BIPFont.caption()).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                Button {
                    withAnimation { didStart = true }
                    diagnosticsVM.runAllTests()
                } label: {
                    Label("Start Tests", systemImage: "play.fill")
                        .font(BIPFont.headline())
                        .foregroundStyle(.white)
                        .padding(.horizontal, BIPSpacing.lg)
                        .padding(.vertical, BIPSpacing.sm)
                        .background(Capsule().fill(LinearGradient(colors: Color.bip.accentGradient, startPoint: .leading, endPoint: .trailing)))
                }
            }.padding(.vertical, BIPSpacing.lg)
        }
    }

    private var progressSection: some View {
        Group {
            if diagnosticsVM.isRunning {
                GlassCard {
                    HStack(spacing: BIPSpacing.md) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.bip.accent))
                        Text("Running diagnostics…")
                            .font(BIPFont.body())
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }

    private var itemsSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Hardware Tests", icon: "checklist", iconColor: Color.bip.accent)
                ForEach(diagnosticsVM.items) { item in
                    diagnosticRow(item)
                    if item.id != diagnosticsVM.items.last?.id { Divider().opacity(0.2) }
                }
            }
        }
    }

    private func diagnosticRow(_ item: HardwareDiagnosticItem) -> some View {
        HStack(spacing: BIPSpacing.sm) {
            Image(systemName: item.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(item.result.colorName))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(BIPFont.body(weight: .medium))
                if !item.detail.isEmpty {
                    Text(item.detail).font(BIPFont.caption()).foregroundStyle(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                if case .running = item.result {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.bip.accent)).scaleEffect(0.7)
                } else {
                    Image(systemName: item.result.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(item.result.colorName))
                }
                Text(item.result.shortLabel)
                    .font(BIPFont.caption(weight: .semibold))
                    .foregroundStyle(Color(item.result.colorName))
            }
        }
    }

    private func summarySection(_ report: HardwareDiagnosticsReport) -> some View {
        GlassCard {
            HStack(spacing: BIPSpacing.lg) {
                ScoreRing(score: report.overallScore, title: "Hardware", size: 100)
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(report.passCount) Passed",   systemImage: "checkmark.circle.fill").font(BIPFont.body()).foregroundStyle(Color.bip.green)
                    Label("\(report.warningCount) Warnings", systemImage: "exclamationmark.triangle.fill").font(BIPFont.body()).foregroundStyle(Color.bip.yellow)
                    Label("\(report.failCount) Failed",   systemImage: "xmark.circle.fill").font(BIPFont.body()).foregroundStyle(Color.bip.red)
                }
            }
        }
    }
}
