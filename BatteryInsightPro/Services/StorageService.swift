// StorageService.swift
// Battery Insight Pro

import Foundation

final class StorageService {
    static let shared = StorageService()
    private init() {}

    func currentInfo() -> StorageInfo {
        StorageInfo.current()
    }
}
