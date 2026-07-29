// PersistenceService.swift
// Battery Insight Pro — Core Data stack

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private init() {}

    // MARK: - Charging Sessions
    // This project intentionally uses UserDefaults for these lightweight records.
    // There is no Core Data model in the bundle, so creating an NSPersistentContainer
    // here would fail at runtime.
    func saveChargingSession(_ session: ChargingSession) {
        var sessions = loadChargingSessions()
        sessions.append(session)
        if sessions.count > 500 { sessions.removeFirst() }
        if let data = try? JSONEncoder().encode(sessions.map { CodableSession(from: $0) }) {
            UserDefaults.standard.set(data, forKey: "chargingSessions")
        }
    }

    func loadChargingSessions() -> [ChargingSession] {
        guard let data = UserDefaults.standard.data(forKey: "chargingSessions"),
              let coded = try? JSONDecoder().decode([CodableSession].self, from: data) else { return [] }
        return coded.map { $0.toSession() }
    }
}

struct CodableSession: Codable {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var startLevel: Double
    var endLevel: Double
    var peakLevel: Double
    var averageEfficiency: Double
    var chargingSpeedLabel: String

    init(from s: ChargingSession) {
        id = s.id; startDate = s.startDate; endDate = s.endDate
        startLevel = s.startLevel; endLevel = s.endLevel; peakLevel = s.peakLevel
        averageEfficiency = s.averageEfficiency; chargingSpeedLabel = s.chargingSpeedLabel
    }
    func toSession() -> ChargingSession {
        ChargingSession(id: id, startDate: startDate, endDate: endDate,
                        startLevel: startLevel, endLevel: endLevel, peakLevel: peakLevel,
                        averageEfficiency: averageEfficiency, chargingSpeedLabel: chargingSpeedLabel)
    }
}
