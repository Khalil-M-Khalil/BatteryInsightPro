// StorageViewModel.swift
// Battery Insight Pro

import SwiftUI
import Combine

final class StorageViewModel: ObservableObject {
    @Published var info: StorageInfo = StorageInfo.current()
    @Published var isRefreshing = false

    private var timer: AnyCancellable?

    init() {
        refresh()
        startTimer()
    }

    func refresh() {
        isRefreshing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let s = StorageInfo.current()
            DispatchQueue.main.async {
                self.info = s
                self.isRefreshing = false
            }
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
    }

    var usedLabel: String  { ByteFormatter.string(info.usedBytes) }
    var freeLabel: String  { ByteFormatter.string(info.freeBytes) }
    var totalLabel: String { ByteFormatter.string(info.totalBytes) }
    var cacheLabel: String { ByteFormatter.string(info.cacheBytes) }

    var donutSlices: [DonutChart.Slice] {
        [
            .init(label: "Photos",    value: Double(info.photoBytes),    color: Color.bip.orange),
            .init(label: "Videos",    value: Double(info.videoBytes),    color: Color.bip.purple),
            .init(label: "Apps",      value: Double(info.appBytes),      color: Color.bip.accent),
            .init(label: "Documents", value: Double(info.documentBytes), color: Color.bip.yellow),
            .init(label: "System",    value: Double(info.systemBytes),   color: Color.gray),
            .init(label: "Cache",     value: Double(info.cacheBytes),    color: Color.bip.mint),
            .init(label: "Other",     value: Double(info.otherBytes),    color: Color(white: 0.5)),
        ]
    }

    var categories: [(name: String, bytes: Int64, color: Color, icon: String)] {
        [
            ("Photos",    info.photoBytes,    Color.bip.orange, "photo.fill"),
            ("Videos",    info.videoBytes,    Color.bip.purple, "video.fill"),
            ("Apps",      info.appBytes,      Color.bip.accent, "app.fill"),
            ("Documents", info.documentBytes, Color.bip.yellow, "doc.fill"),
            ("Cache",     info.cacheBytes,    Color.bip.mint,   "archivebox.fill"),
            ("Downloads", info.downloadBytes, Color.bip.green,  "arrow.down.circle.fill"),
            ("System",    info.systemBytes,   Color.gray,       "gearshape.fill"),
            ("Temp",      info.tempBytes,     Color(white: 0.6),"clock.fill"),
            ("Other",     info.otherBytes,    Color(white: 0.4),"ellipsis.circle.fill"),
        ]
    }
}
