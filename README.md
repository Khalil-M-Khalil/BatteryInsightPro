# Battery Insight Pro
### Premium iOS Battery & Device Health Application

---

## Overview

**Battery Insight Pro** is a production-quality SwiftUI application targeting **iOS 16.0+** that provides comprehensive battery analysis, system health monitoring, hardware diagnostics, performance tracking, and storage analysis.

The app is built entirely with **native Apple APIs** and is fully transparent about which metrics are available on a standard (non-jailbroken) device.

---

## Project Structure

```
BatteryInsightPro/
├── BatteryInsightPro/              # Main app target
│   ├── App/
│   │   ├── BatteryInsightProApp.swift   # @main entry point
│   │   └── ContentView.swift            # Root TabView
│   ├── Models/
│   │   ├── BatteryInfo.swift            # Battery data model + availability labels
│   │   ├── SystemInfo.swift             # CPU, RAM, OS info models
│   │   ├── StorageInfo.swift            # Storage breakdown model
│   │   └── HardwareDiagnostic.swift     # Diagnostic results, errors, scores
│   ├── Services/
│   │   ├── BatteryService.swift         # Public API battery reading + estimation
│   │   ├── SystemService.swift          # Darwin host_statistics CPU/RAM
│   │   ├── StorageService.swift         # FileManager storage attributes
│   │   ├── PerformanceService.swift     # 1-second performance sampling
│   │   ├── NotificationService.swift    # UserNotifications alerts
│   │   ├── PersistenceService.swift     # Core Data + UserDefaults sessions
│   │   └── PDFReportService.swift       # PDFKit report generation
│   ├── ViewModels/
│   │   ├── BatteryViewModel.swift       # Battery state + charging session tracking
│   │   ├── SystemViewModel.swift        # System info with 2s refresh
│   │   ├── StorageViewModel.swift       # Storage with donut chart data
│   │   ├── PerformanceViewModel.swift   # 1s live chart data streams
│   │   ├── DiagnosticsViewModel.swift   # Hardware test orchestration
│   │   └── SettingsViewModel.swift      # @AppStorage preferences
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── DesignSystem.swift       # Colors, fonts, spacing tokens
│   │   │   ├── GlassCard.swift          # Glassmorphism card containers
│   │   │   ├── CircularGauge.swift      # Animated circular progress rings
│   │   │   ├── StatusBadge.swift        # Availability badges, metric rows
│   │   │   └── LiveChart.swift          # Swift Charts wrappers
│   │   ├── Dashboard/DashboardView.swift
│   │   ├── Battery/
│   │   │   ├── BatteryDetailView.swift
│   │   │   └── BatteryDiagnosticsView.swift
│   │   ├── System/SystemAnalyzerView.swift
│   │   ├── Performance/PerformanceMonitorView.swift
│   │   ├── Storage/StorageAnalyzerView.swift
│   │   ├── Apps/AppAnalyzerView.swift
│   │   ├── Charging/ChargingHistoryView.swift
│   │   ├── Hardware/
│   │   │   ├── HardwareDiagnosticsView.swift
│   │   │   └── ErrorDetectionView.swift
│   │   ├── Reports/ReportsView.swift
│   │   └── Settings/SettingsView.swift
│   ├── Resources/Assets.xcassets
│   └── Info.plist
├── BatteryInsightProWidget/
│   └── BatteryWidget.swift              # Small/Medium/Large home screen widgets
├── BatteryInsightPro.xcodeproj
└── README.md
```

---

## Requirements

| Requirement | Value |
|---|---|
| **iOS Deployment Target** | iOS 16.0 |
| **Xcode Version** | Xcode 15+ |
| **Swift Version** | Swift 5.9 |
| **Frameworks** | SwiftUI, Charts, WidgetKit, CoreData, PDFKit, CoreMotion, AVFoundation, CoreLocation, UserNotifications |
| **Architecture** | MVVM + Combine + Async/Await |

---

## Setup Instructions

### 1. Open in Xcode

```bash
open BatteryInsightPro.xcodeproj
```

### 2. Configure Signing

1. Select the `BatteryInsightPro` target
2. Go to **Signing & Capabilities**
3. Set your **Team** and **Bundle Identifier** (e.g. `com.yourname.batteryinsightpro`)
4. Do the same for the `BatteryInsightProWidget` extension

### 3. Add Capabilities

In **Signing & Capabilities**, add:
- **Background Modes** → Background App Refresh
- **App Groups** → `group.com.batteryinsightpro` (for widget data sharing)
- **Push Notifications** (optional)

### 4. Build & Run

Select an **iPhone device or simulator** (iOS 16+) and press **⌘R**.

> ⚠️ **Battery level always returns -1 on iOS Simulator.** Run on a real device for live battery data.

---

## Metric Availability Labels

Every metric in the app is clearly labeled:

| Label | Meaning |
|---|---|
| 🟢 **Live** | Read directly from a public Apple API |
| 🟡 **Estimated** | Derived/calculated from observable data |
| 🔴 **Unavailable** | Requires private IOKit — not accessible on App Store apps |

### What's Live (Public API)
- Battery Level — `UIDevice.batteryLevel`
- Charging State — `UIDevice.batteryState`
- Low Power Mode — `ProcessInfo.isLowPowerModeEnabled`
- Thermal State — `ProcessInfo.thermalState`
- iOS Version, Device Model — `UIDevice` / `ProcessInfo`
- CPU Usage — Darwin `host_statistics`
- RAM Usage — Darwin `host_statistics64`
- Total/Free Storage — `FileManager` volume attributes

### What's Estimated
- Battery Health % (discharge pattern analysis)
- Screen/Standby Time Remaining
- Battery Chemistry (device generation inference)
- Charging Efficiency (session history)
- Wear Level, Condition, Lifetime Prediction

### What's Unavailable (IOKit Private)
- Battery Temperature
- Battery Voltage
- Battery Current (mA)
- Cycle Count
- Manufacture Date
- Design / Maximum Capacity (mAh)
- Charging Speed (Watts)
- GPU Usage
- Per-app battery drain
- Frame Rate (FPS)

---

## Features

### 📊 Dashboard
- Dual animated circular gauges (battery level + health)
- Quick stats grid: screen time, standby, charge efficiency, wear level
- System overview with mini CPU/RAM gauges
- Device health score rings (battery, system, storage)
- Smart recommendations

### 🔋 Battery Detail & Diagnostics
- Complete metric table with availability badges
- Tap unavailable metrics to read why
- Full diagnostic report: degradation, drain, heat, calibration
- Automatic recommendations
- Health score (0–100)

### 💻 System Analyzer
- Device info, iOS version, kernel, uptime
- Live CPU & RAM circular gauges with gradient colors
- Thermal state with contextual description
- Memory pressure indicator
- Detected issue cards with severity ratings

### ⚡ Performance Monitor
- 1-second updating live line charts: CPU, RAM, Battery
- Thermal state live indicator
- Honest note on unavailable metrics (GPU, FPS, network quality)

### 💾 Storage Analyzer
- Total/Used/Free with animated progress bar
- Animated donut chart breakdown by category
- Per-category horizontal bars
- Storage score + cleanup recommendations

### 🔧 Hardware Diagnostics
- Tests: Accelerometer, Gyroscope, Magnetometer, GPS, Cameras, Microphone, Wi-Fi, Bluetooth, Face ID, NFC, Speaker, Haptic, Touch
- Pass / Warning / Failed / N/A results
- Hardware score ring

### 📋 Reports
- Full Device / Battery / Hardware PDF reports
- Generated with PDFKit
- Share via standard iOS share sheet

### 🔔 Notifications
- Low battery alert (< 20%)
- High temperature alert
- Storage low alert (< 10%)
- Monthly battery calibration reminder

### 🏠 Home Screen Widgets
- Small: Battery level + charging state
- Medium: Ring + stats
- Large: Full dashboard widget

### ⚙️ Settings
- Dark / Light / Automatic theme
- °C / °F toggle
- Refresh interval
- Notification controls
- API Transparency screen
- Report language

---

## Architecture

```
View  ←→  ViewModel  ←→  Service  ←→  iOS APIs
 │            │               │
SwiftUI    @Published      Darwin
           Combine        UIKit
           @AppStorage    CoreMotion
                          AVFoundation
                          FileManager
                          PDFKit
```

- **ViewModels** use `Timer.publish` for periodic refresh
- **BatteryViewModel** tracks charging sessions via `UIDevice` notifications
- **DiagnosticsViewModel** orchestrates async hardware tests
- **PersistenceService** stores sessions in `UserDefaults` (JSON-encoded)
- **PerformanceService** maintains a 120-entry ring buffer for charts

---

## Limitations & Honest Notes

This app does NOT use any private APIs. The following are specifically NOT available on App Store apps:
- `IOKit.framework` (battery temp, voltage, mA, cycle count, capacity)
- Private `MobileGestalt` (hardware capability flags)
- Private `CoreTelephony` (signal quality, carrier data)
- `SpringBoardServices` (installed app list with battery data)

This is by design. The app is transparent, accurate, and App Store–safe.

---

## License

MIT License — Free to use, modify, and distribute.

---

*Built with ❤️ using SwiftUI, Swift Charts, WidgetKit, and PDFKit*
*Target: iOS 16.7+ | Xcode 15 | Swift 5.9*
