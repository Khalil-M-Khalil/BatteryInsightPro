// swift-tools-version:5.9
// Package.swift — alternative SPM manifest (optional)
// The primary build is via BatteryInsightPro.xcodeproj

import PackageDescription

let package = Package(
    name: "BatteryInsightPro",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "BatteryInsightPro", targets: ["BatteryInsightPro"])
    ],
    targets: [
        .target(
            name: "BatteryInsightPro",
            path: "BatteryInsightPro",
            exclude: ["Info.plist"]
        )
    ]
)
