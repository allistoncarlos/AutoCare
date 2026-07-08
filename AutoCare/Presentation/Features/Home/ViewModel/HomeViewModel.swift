//
//  HomeViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension HomeView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var state: HomeState = .idle
        @Published private(set) var selectedVehicle: Vehicle?

        private let networkConnectivity = NetworkConnectivity()
        private var cancellables = Set<AnyCancellable>()

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.syncService) private var syncService
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository
        @Injected(\.vehicleRepository) private var vehicleRepository
        @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
        @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

        init() {
            networkConnectivity.$status
                .receive(on: RunLoop.main)
                .sink { [weak self] status in
                    guard status == .connected else { return }
                    Task { await self?.syncData() }
                }
                .store(in: &cancellables)
        }

        func showEditVehicleView(
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            HomeRouter.makeEditVehicleView(
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }

        func showPulseUI() -> some View {
            HomeRouter.makePulseUI()
        }

        func fetchData() async {
            state = .loading

            let isConnected = networkConnectivity.status == .connected
            if isConnected {
                await fetchRemote()
            }

            do {
                let vehicles: [Vehicle] = try await swiftDataManager.fetch(sortBy: [SortDescriptor(\.name)])
                state = vehicles.isEmpty ? .newVehicle : .successVehicle(vehicles)

                if vehicles.isEmpty {
                    selectedVehicle = nil
                } else if selectedVehicle == nil {
                    selectedVehicle = vehicles.first(where: \.isDefault) ?? vehicles.first
                }
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }

        func syncData() async {
            await syncService.sync()
        }

        @discardableResult
        func requestAuthorizationForNotifications() async -> Bool {
            let notificationCenter = UNUserNotificationCenter.current()
            let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

            do {
                return try await notificationCenter.requestAuthorization(options: authorizationOptions)
            } catch {
                print(error)
                return false
            }
        }

        private func fetchRemote() async {
            await syncService.pullRemoteChanges()
        }
    }
}
