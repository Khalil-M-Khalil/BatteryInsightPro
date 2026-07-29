// ReportsView.swift
// Battery Insight Pro — PDF report generation and sharing

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @EnvironmentObject var systemVM: SystemViewModel
    @EnvironmentObject var storageVM: StorageViewModel
    @State private var isGenerating = false
    @State private var pdfURL: URL?
    @State private var showShare = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    headerCard
                    reportTypeSection
                    if let url = pdfURL {
                        shareSection(url)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showShare) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var headerCard: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.bip.accent)
                Text("Professional Reports")
                    .font(BIPFont.title2())
                Text("Generate and export detailed PDF reports about your device's battery, health, and diagnostics.")
                    .font(BIPFont.body())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }.padding(.vertical, BIPSpacing.sm)
        }
    }

    private var reportTypeSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "Generate Report", icon: "doc.badge.plus", iconColor: Color.bip.accent)

                reportButton(
                    title: "Full Device Report",
                    subtitle: "Battery, system, storage, and recommendations",
                    icon: "doc.text.magnifyingglass",
                    gradient: Color.bip.accentGradient
                ) {
                    generateReport(type: .full)
                }

                reportButton(
                    title: "Battery Report",
                    subtitle: "Health, diagnostics, and charging history",
                    icon: "battery.100.bolt",
                    gradient: Color.bip.batteryGradient
                ) {
                    generateReport(type: .battery)
                }

                reportButton(
                    title: "Hardware Diagnostics",
                    subtitle: "Sensor and hardware test results",
                    icon: "checklist",
                    gradient: Color.bip.warmGradient
                ) {
                    generateReport(type: .hardware)
                }
            }
        }
    }

    private func reportButton(title: String, subtitle: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AccentCard(gradient: gradient) {
                HStack(spacing: BIPSpacing.md) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(gradient.first ?? Color.bip.accent)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title).font(BIPFont.body(weight: .semibold))
                        Text(subtitle).font(BIPFont.caption()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if isGenerating {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.bip.accent))
                    } else {
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .disabled(isGenerating)
    }

    private func shareSection(_ url: URL) -> some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.bip.green).font(.system(size: 20))
                    Text("Report Ready").font(BIPFont.headline())
                    Spacer()
                }
                Text(url.lastPathComponent).font(BIPFont.caption()).foregroundStyle(.secondary)
                Button {
                    showShare = true
                } label: {
                    Label("Share Report", systemImage: "square.and.arrow.up")
                        .font(BIPFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BIPSpacing.sm)
                        .background(Capsule().fill(LinearGradient(colors: Color.bip.accentGradient, startPoint: .leading, endPoint: .trailing)))
                }
            }
        }
    }

    fileprivate enum ReportType { case full, battery, hardware }

    private func generateReport(type: ReportType) {
        isGenerating = true
        pdfURL = nil
        Task {
            let url = await PDFReportService.shared.generate(
                battery: batteryVM.info,
                system: systemVM.info,
                storage: storageVM.info,
                reportType: type.name
            )
            await MainActor.run {
                pdfURL = url
                isGenerating = false
            }
        }
    }
}

extension ReportsView.ReportType {
    var name: String {
        switch self {
        case .full:     return "Full Device Report"
        case .battery:  return "Battery Report"
        case .hardware: return "Hardware Diagnostics"
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
