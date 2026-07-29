//
//  AutoCareApp+SwiftDataInjection.swift
//  AutoCare
//

import Factory
import Foundation

extension Container {
    var authSessionStore: Factory<AuthSessionStore> {
        self { @MainActor in AuthSessionStore() }
            .singleton
    }

    var swiftDataManager: Factory<SwiftDataManager> {
        self { @MainActor in SwiftDataManager.shared }
    }

    var syncService: Factory<SyncService> {
        self { @MainActor in SyncService() }
            .singleton
    }
}
