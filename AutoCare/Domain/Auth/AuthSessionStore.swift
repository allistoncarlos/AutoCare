//
//  AuthSessionStore.swift
//  AutoCare
//

import Combine
import Factory
import SwiftData
import SwiftUI

@MainActor
final class AuthSessionStore: ObservableObject {
    @Published private(set) var isAuthenticated: Bool

    init() {
        isAuthenticated = KeychainDataSource.hasValidToken()
    }

    func markAuthenticated() {
        isAuthenticated = true
    }

    func logout(clearLocalData: Bool = true) {
        KeychainDataSource.clear()
        SyncState.reset()
        isAuthenticated = false

        #if canImport(WatchConnectivity) && os(iOS)
        Task { @MainActor in
            await WatchPhoneCoordinator.shared.pushVehiclesToWatch()
        }
        #endif

        guard clearLocalData else { return }

        Task { @MainActor in
            await Task.yield()
            clearSwiftDataStore()
        }
    }

    private func clearSwiftDataStore() {
        do {
            try SwiftDataManager.shared.container.erase()
        } catch {
            print(error.localizedDescription)
        }
    }
}
