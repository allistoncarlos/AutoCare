//
//  HomeViewModel.swift
//  AutoCare Watch App
//

import Combine
import Foundation

enum WatchHomeUIState: Equatable {
    case loading
    case notLogged
    case empty
    case content
    case error(String)
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var vehicles: [WatchVehicle] = []
    @Published var uiState: WatchHomeUIState = .loading

    private let service = WatchMileageService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        WatchConnectivityManager.shared.$context
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyCachedVehiclesIfNeeded()
            }
            .store(in: &cancellables)

        WatchConnectivityManager.shared.$cachedPayload
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyCachedVehiclesIfNeeded()
            }
            .store(in: &cancellables)

        WatchConnectivityManager.shared.$cachedAuthStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self, let status else { return }
                if status == .notLogged, vehicles.isEmpty {
                    uiState = .notLogged
                }
            }
            .store(in: &cancellables)
    }

    func load() async {
        WatchConnectivityManager.shared.refreshCachedPayload()
        applyCachedVehiclesIfNeeded()

        if uiState == .content || uiState == .empty || uiState == .notLogged {
            await refreshFromPhone()
            return
        }

        uiState = .loading
        await refreshFromPhone()
    }

    private func refreshFromPhone() async {
        do {
            try await service.checkAuth()
            let fetched = try await service.fetchVehicles(forceRefresh: uiState == .loading)
            vehicles = fetched
            uiState = fetched.isEmpty ? .empty : .content
        } catch WatchMileageServiceError.notLogged {
            vehicles = []
            uiState = .notLogged
        } catch {
            if vehicles.isEmpty {
                uiState = .error(error.localizedDescription)
            }
        }
    }

    private func applyCachedVehiclesIfNeeded() {
        if WatchConnectivityManager.shared.cachedAuthStatus == .notLogged {
            vehicles = []
            uiState = .notLogged
            return
        }

        guard let cached = WatchConnectivityManager.shared.vehiclesFromContext()?.vehicles else {
            return
        }

        vehicles = cached
        uiState = cached.isEmpty ? .empty : .content
    }
}
