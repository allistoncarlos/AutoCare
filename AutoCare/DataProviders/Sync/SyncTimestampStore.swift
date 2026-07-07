//
//  SyncTimestampStore.swift
//  AutoCare
//

import Foundation

enum SyncTimestampStore {
    private static let key = "autocare.lastSync"

    static var lastSync: Date? {
        get {
            guard let value = UserDefaults.standard.string(forKey: key) else { return nil }
            return ISO8601DateFormatter().date(from: value)
        }
        set {
            if let newValue {
                UserDefaults.standard.set(ISO8601DateFormatter().string(from: newValue), forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
