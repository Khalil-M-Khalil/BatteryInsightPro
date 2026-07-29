// StorageAnalyzerView.swift
// Battery Insight Pro

import SwiftUI

struct StorageAnalyzerView: View {
    @EnvironmentObject var storageVM: StorageViewModel

    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    overviewSection
                    donutSection
                    categoriesSection
                    recommendationsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.large)
    }

    private var overviewSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "Storage Overview", icon: "internaldrive.fill", iconColor: Color.bip.accent)
                // Usage bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        Capsule()
                            .fill(LinearGradient(colors: storageGradient, startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * storageVM.info.usedPercent / 100, height: 12)
                            .animation(.spring(response: 1.0), value: storageVM.info.usedPercent)
                    }
                }
                .frame(height: 12)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(storageVM.usedLabel)
                            .font(BIPFont.headline(weight: .bold))
                        Text("Used")
                            .font(BIPFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text(String(format: "%.0f%%", storageVM.info.usedPercent))
                            .font(BIPFont.headline(weight: .bold))
                            .foregroundStyle(storageColor)
                        Text("Used")
                            .font(BIPFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(storageVM.freeLabel)
                            .font(BIPFont.headline(weight: .bold))
                            .foregroundStyle(Color.bip.green)
                        Text("Free")
                            .font(BIPFont.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                Divider().opacity(0.2)
                HStack {
                    Label("Total: " + storageVM.totalLabel, systemImage: "internaldrive")
                        .font(BIPFont.caption())
                        .foregroundStyle(.secondary)
                    Spacer()
                    AvailabilityBadge(availability: .live)
                }
            }
        }
    }

    private var storageGradient: [Color] {
        storageVM.info.usedPercent > 85 ? Color.bip.dangerGradient : Color.bip.accentGradient
    }

    private var storageColor: Color {
        storageVM.info.usedPercent > 85 ? Color.bip.red
        : storageVM.info.usedPercent > 70 ? Color.bip.orange
        : Color.bip.accent
    }

    private var donutSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.md) {
                SectionHeader(title: "Storage Breakdown", icon: "chart.pie.fill", iconColor: Color.bip.purple)
                HStack(alignment: .center, spacing: BIPSpacing.lg) {
                    DonutChart(slices: storageVM.donutSlices, size: 150)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(storageVM.donutSlices.prefix(5)) { slice in
                            HStack(spacing: 6) {
                                Circle().fill(slice.color).frame(width: 8, height: 8)
                                Text(slice.label)
                                    .font(BIPFont.caption())
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(ByteFormatter.string(Int64(slice.value)))
                                    .font(BIPFont.caption(weight: .semibold))
                            }
                        }
                    }
                }
            }
        }
    }

    private var categoriesSection: some View {
        GlassCard {
            VStack(spacing: BIPSpacing.sm) {
                SectionHeader(title: "Categories", icon: "folder.fill", iconColor: Color.bip.yellow)
                ForEach(storageVM.categories, id: \.name) { cat in
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: cat.icon)
                                .foregroundStyle(cat.color)
                                .frame(width: 24)
                            Text(cat.name)
                                .font(BIPFont.body())
                            Spacer()
                            Text(ByteFormatter.string(cat.bytes))
                                .font(BIPFont.body(weight: .semibold))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(cat.color.opacity(0.15)).frame(height: 4)
                                Capsule()
                                    .fill(cat.color)
                                    .frame(width: geo.size.width * barWidth(cat.bytes), height: 4)
                                    .animation(.spring(response: 1.0), value: barWidth(cat.bytes))
                            }
                        }
                        .frame(height: 4)
                        if cat.name != storageVM.categories.last?.name {
                            Divider().opacity(0.15)
                        }
                    }
                }
            }
        }
    }

    private func barWidth(_ bytes: Int64) -> Double {
        guard storageVM.info.usedBytes > 0 else { return 0 }
        return min(1.0, Double(bytes) / Double(storageVM.info.usedBytes))
    }

    private var recommendationsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: BIPSpacing.sm) {
                SectionHeader(title: "Recommendations", icon: "lightbulb.fill", iconColor: Color.bip.yellow)
                ForEach(storageVM.info.recommendations, id: \.self) { rec in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(Color.bip.accent).font(.system(size: 14)).padding(.top, 2)
                        Text(rec).font(BIPFont.body()).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
