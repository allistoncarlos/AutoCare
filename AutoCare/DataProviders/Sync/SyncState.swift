//
//  SyncState.swift
//  AutoCare
//

import Foundation

enum SyncState {
    private static let key = "autocare.lastServerSyncAt"
    private static let lastRunKey = "autocare.lastSyncRunAt"

    static var lastSyncRunAt: Date? {
        get { UserDefaults.standard.object(forKey: lastRunKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastRunKey) }
    }

    static var lastServerSyncAt: Date? {
        get {
            guard let value = UserDefaults.standard.string(forKey: key) else { return nil }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: value)
        }
        set {
            if let date = newValue {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                UserDefaults.standard.set(formatter.string(from: date), forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    static func reset() {
        lastServerSyncAt = nil
        lastSyncRunAt = nil
    }
}
