// ErrorDetectionView.swift
// Battery Insight Pro

import SwiftUI

struct ErrorDetectionView: View {
    @EnvironmentObject var systemVM: SystemViewModel
    @EnvironmentObject var batteryVM: BatteryViewModel
    @EnvironmentObject var storageVM: StorageViewModel

    var allErrors: [ErrorItem] {
        var errs = systemVM.deviceErrors
        if batteryVM.info.healthPercentage < 80 {
            errs.append(ErrorItem(
                title: "Battery Degradation",
                description: "Battery health has dropped below 80%. Maximum capacity is significantly reduced.",
                severity: .high,
                icon: "battery.slash",
                recommendation: "Visit an Apple Authorized Service Provider for battery replacement."
            ))
        }
        if storageVM.info.freePercent < 10 {
            errs.append(ErrorItem(
                title: "Storage Critically Low",
                description: "Less than 10% storage free. Device performance and stability may be affected.",
                severity: .high,
                icon: "internaldrive",
                recommendation: "Delete unused apps, photos, and downloads to free space."
            ))
        }
        return errs
    }

    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    if allErrors.isEmpty {
                        GlassCard {
                            VStack(spacing: BIPSpacing.md) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 52)).foregroundStyle(Color.bip.green)
                                Text("No Issues Detected")
                                    .font(BIPFont.title2())
                                Text("Your device appears to be running well. No errors or warnings found.")
                                    .font(BIPFont.body()).foregroundStyle(.secondary).multilineTextAlignment(.center)
                            }.padding(.vertical, BIPSpacing.lg)
                        }.padding(.horizontal)
                    } else {
                        ForEach(allErrors) { err in
                            GlassCard { ErrorCard(item: err) }.padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Error Detection")
        .navigationBarTitleDisplayMode(.large)
    }
}
