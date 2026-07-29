// BatteryViewModel.swift
// Battery Insight Pro

import SwiftUI
import Combine

final class BatteryViewModel: ObservableObject {
    @Published var info: BatteryInfo = .placeholder()
    @Published var diagnosticReport: BatteryDiagnosticReport?
    @Published var isRefreshing = false

    private var timer: AnyCancellable?
    private let service = BatteryService.shared
    private let persistence = PersistenceService.shared

    // Track charging sessions
    @Published var sessions: [ChargingSession] = []
    private var activeSession: ChargingSession?
    private var lastState: BatteryState = .unknown

    init() {
        sessions = persistence.loadChargingSessions()
        refresh()
        startTimer()
        observeBatteryNotifications()
    }

    func refresh() {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.info = self.service.buildInfo(sessions: self.sessions)
            self.isRefreshing = false
        }
    }

    func runDiagnostics() {
        diagnosticReport = service.generateDiagnosticReport(info: info, sessions: sessions)
    }

    private func startTimer() {
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.info = self.service.buildInfo(sessions: self.sessions)
                self.trackChargingSession()
                NotificationService.shared.scheduleLowBatteryAlert(level: self.info.level)
                NotificationService.shared.scheduleHighThermalAlert(state: self.info.thermalState)
            }
    }

    private func trackChargingSession() {
        let currentState = info.state
        // Started charging
        if currentState == .charging && lastState != .charging {
            activeSession = ChargingSession(
                id: UUID(), startDate: Date(), endDate: nil,
                startLevel: info.level, endLevel: info.level,
                peakLevel: info.level, averageEfficiency: 94.0,
                chargingSpeedLabel: "Standard"
            )
        }
        // Stopped charging
        if currentState != .charging && lastState == .charging, var s = activeSession {
            s.endDate = Date()
            s.endLevel = info.level
            s.peakLevel = max(s.peakLevel, info.level)
            sessions.append(s)
            if sessions.count > 200 { sessions.removeFirst() }
            persistence.saveChargingSession(s)
            activeSession = nil
        }
        // Update active session peak
        if currentState == .charging, var s = activeSession {
            s.peakLevel = max(s.peakLevel, info.level)
            activeSession = s
        }
        lastState = currentState
    }

    private func observeBatteryNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil, queue: .main) { [weak self] _ in
            self?.refresh()
        }
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil, queue: .main) { [weak self] _ in
            self?.info = BatteryService.shared.buildInfo(sessions: self?.sessions ?? [])
        }
    }

    // Formatted helpers
    var levelPercent: String { "\(Int(info.level * 100))%" }
    var healthPercent: String { "\(Int(info.healthPercentage))%" }
    var screenTimeLabel: String { formatTime(info.screenTimeRemaining) }
    var standbyTimeLabel: String { formatTime(info.standbyTimeRemaining) }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    var stateColor: Color {
        switch info.state {
        case .charging:    return Color.bip.green
        case .discharging: return Color.bip.orange
        case .full:        return Color.bip.accent
        case .unknown:     return Color.gray
        }
    }

    var thermalColor: Color {
        switch info.thermalState {
        case .nominal:  return Color.bip.green
        case .fair:     return Color.bip.yellow
        case .serious:  return Color.bip.orange
        case .critical: return Color.bip.red
        @unknown default: return Color.gray
        }
    }
}
