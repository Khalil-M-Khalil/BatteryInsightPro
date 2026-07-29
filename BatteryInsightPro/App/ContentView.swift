// ContentView.swift
// Battery Insight Pro — Root tab bar navigation

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var batteryVM: BatteryViewModel
    @EnvironmentObject var systemVM: SystemViewModel
    @EnvironmentObject var storageVM: StorageViewModel
    @EnvironmentObject var performanceVM: PerformanceViewModel
    @EnvironmentObject var diagnosticsVM: DiagnosticsViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel

    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            BIPBackground()
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                    .tag(0)

                BatteryDetailView()
                    .tabItem { Label("Battery", systemImage: "battery.100.bolt") }
                    .tag(1)

                SystemAnalyzerView()
                    .tabItem { Label("System", systemImage: "cpu") }
                    .tag(2)

                PerformanceMonitorView()
                    .tabItem { Label("Performance", systemImage: "waveform.path.ecg") }
                    .tag(3)

                MoreView()
                    .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
                    .tag(4)
            }
            .accentColor(Color.bip.accent)
        }
        .onAppear {
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}

struct MoreView: View {
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                BIPBackground()
                List {
                    NavigationLink("Storage Analyzer")   { StorageAnalyzerView() }
                    NavigationLink("App Analyzer")        { AppAnalyzerView() }
                    NavigationLink("Charging History")    { ChargingHistoryView() }
                    NavigationLink("Hardware Diagnostics"){ HardwareDiagnosticsView() }
                    NavigationLink("Error Detection")     { ErrorDetectionView() }
                    NavigationLink("Reports")             { ReportsView() }
                    NavigationLink("Settings")            { SettingsView() }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
