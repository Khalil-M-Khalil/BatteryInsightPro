// SettingsViewModel.swift
// Battery Insight Pro

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    @AppStorage("themeMode")          var themeMode: String = "auto"
    @AppStorage("temperatureUnit")    var temperatureUnit: String = "celsius"
    @AppStorage("refreshInterval")    var refreshInterval: Int = 5
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("reportLanguage")     var reportLanguage: String = "English"

    var colorScheme: ColorScheme? {
        switch themeMode {
        case "dark":  return .dark
        case "light": return .light
        default:      return nil
        }
    }

    var themeModeLabel: String {
        switch themeMode {
        case "dark":  return "Dark"
        case "light": return "Light"
        default:      return "Automatic"
        }
    }

    func temperatureString(_ celsius: Double) -> String {
        if temperatureUnit == "fahrenheit" {
            return String(format: "%.1f°F", celsius * 9/5 + 32)
        }
        return String(format: "%.1f°C", celsius)
    }
}
