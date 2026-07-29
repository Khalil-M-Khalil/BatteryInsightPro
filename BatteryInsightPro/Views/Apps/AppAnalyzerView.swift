// AppAnalyzerView.swift
// Battery Insight Pro

import SwiftUI

// Note: Installed app list and per-app battery/storage breakdown requires
// private APIs not available on App Store apps. We display system-level
// info with clear explanations.
struct AppAnalyzerView: View {
    var body: some View {
        ZStack {
            BIPBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: BIPSpacing.lg) {
                    GlassCard {
                        VStack(spacing: BIPSpacing.md) {
                            Image(systemName: "apps.iphone")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.bip.accent)
                            Text("App Analyzer")
                                .font(BIPFont.title2())
                            Text("Per-app battery usage, storage, and background activity data require private iOS entitlements not available to App Store apps.\n\nTo view this information:\n• Go to Settings > Battery to see per-app battery usage.\n• Go to Settings > General > iPhone Storage for per-app storage.\n• Go to Settings > Privacy > Background App Refresh to manage background activity.")
                                .font(BIPFont.body())
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, BIPSpacing.md)
                    }.padding(.horizontal)

                    GlassCard {
                        VStack(spacing: BIPSpacing.sm) {
                            SectionHeader(title: "What We Can Tell You", icon: "checkmark.circle.fill", iconColor: Color.bip.green)
                            MetricRow(icon: "apps.iphone",  title: "Background App Refresh", value: "See Settings", availability: .unavailable, iconColor: Color.gray, detail: "Required private entitlement")
                            Divider().opacity(0.2)
                            MetricRow(icon: "battery.100",  title: "Per-App Battery Use",     value: "See Settings > Battery", availability: .unavailable, iconColor: Color.gray, detail: "Required private entitlement")
                            Divider().opacity(0.2)
                            MetricRow(icon: "internaldrive",title: "Per-App Storage",         value: "See Settings", availability: .unavailable, iconColor: Color.gray, detail: "Required private entitlement")
                            Divider().opacity(0.2)
                            MetricRow(icon: "moon.fill",    title: "Low Power Mode",          value: ProcessInfo.processInfo.isLowPowerModeEnabled ? "On" : "Off", availability: .live, iconColor: Color.bip.yellow)
                        }
                    }.padding(.horizontal)

                    GlassCard {
                        VStack(alignment: .leading, spacing: BIPSpacing.sm) {
                            SectionHeader(title: "Tip", icon: "lightbulb.fill", iconColor: Color.bip.yellow)
                            Text("To reduce battery usage by apps:\n• Disable Background App Refresh for non-essential apps.\n• Turn off Location Services for apps that don't need it.\n• Review which apps use Bluetooth and Wi-Fi in the background.")
                                .font(BIPFont.body())
                                .foregroundStyle(.secondary)
                        }
                    }.padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("App Analyzer")
        .navigationBarTitleDisplayMode(.large)
    }
}
