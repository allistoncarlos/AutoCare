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

        let modelContext: ModelContext
        private let localStore: LocalDataStore
        private let syncService: SyncService
        private let networkConnectivity = NetworkConnectivity()
        private var cancellables = Set<AnyCancellable>()

        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository
        @Injected(\.vehicleRepository) private var vehicleRepository
        @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
        @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            self.localStore = LocalDataStore(modelContext: modelContext)
            self.syncService = SyncService(modelContext: modelContext)

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
                modelContext: modelContext,
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
                let vehicles: [Vehicle] = try localStore.fetch(sortBy: [SortDescriptor(\.name)])
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
            await syncService.pushUnsyncedChanges()
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
            var vehicleTypes: [VehicleType] = []
            var vehicles: [Vehicle] = []

            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    vehicleTypes = await self.vehicleTypeRepository.fetchData() ?? []
                }
                group.addTask {
                    vehicles = await self.vehicleRepository.fetchData() ?? []
                }
            }

            let vehicleMileages: [VehicleMileage] = await withTaskGroup(of: [VehicleMileage].self) { group in
                for vehicle in vehicles {
                    if let id = vehicle.id {
                        group.addTask {
                            await self.vehicleMileageRepository.fetchData(vehicleId: id) ?? []
                        }
                    }
                }

                var collected: [VehicleMileage] = []
                for await result in group {
                    collected.append(contentsOf: result)
                }
                return collected
            }

            let vehicleServices: [VehicleService] = await withTaskGroup(of: [VehicleService].self) { group in
                for vehicle in vehicles {
                    if let id = vehicle.id {
                        group.addTask {
                            await self.vehicleServiceRepository.fetchData(vehicleId: id) ?? []
                        }
                    }
                }

                var collected: [VehicleService] = []
                for await result in group {
                    collected.append(contentsOf: result)
                }
                return collected
            }

            do {
                try syncService.importRemoteData(
                    vehicleTypes: vehicleTypes,
                    vehicles: vehicles,
                    mileages: vehicleMileages,
                    services: vehicleServices
                )
            } catch {
                print(error)
            }
        }
    }
}
