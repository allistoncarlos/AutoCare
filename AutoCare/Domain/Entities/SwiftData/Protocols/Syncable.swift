//
//  Syncable.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//

import Foundation
import SwiftData

public protocol Syncable: PersistentModel {
    var synced: Bool { get set }
    var clientId: String { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deleted: Bool { get set }
    var deletedAt: Date? { get set }
}

enum SyncDefaults {
    static func newClientId(_ value: String? = nil) -> String {
        value ?? UUID().uuidString
    }
}
