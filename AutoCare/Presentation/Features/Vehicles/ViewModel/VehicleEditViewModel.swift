//
//  VehicleEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Combine
import Factory
import Foundation
import SwiftUI

extension VehicleEditView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var state: VehicleEditState = .idle
        @Published private(set) var vehicleTypes: [VehicleType] = []
        @Published private(set) var vehicle: Vehicle?

        private let vehicleId: String?
        private let networkConnectivity = NetworkConnectivity()

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.vehicleRepository) private var repository
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository

        init(vehicleId: String?) {
            self.vehicleId = vehicleId
        }

        func fetchData() async {
            state = .loading

            if networkConnectivity.status == .connected {
                await fetchRemoteVehicleTypes()
            }

            do {
                vehicleTypes = try await swiftDataManager.fetch(sortBy: [SortDescriptor(\.name)])
                state = .successVehicleTypes(vehicleTypes)

                if let vehicleId {
                    await fetchVehicle(vehicleId: vehicleId)
                }
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }

        func fetchVehicle(vehicleId: String) async {
            state = .loading

            do {
                if let result: Vehicle = try await swiftDataManager.fetchOne(where: #Predicate { $0.id == vehicleId }) {
                    vehicle = result
                    state = .successVehicle(result)
                } else {
                    state = .error
                }
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }

        func save(
            odometer: String,
            name: String,
            brand: String,
            model: String,
            year: String,
            licensePlate: String,
            isDefault: Bool,
            vehicleTypeId: String,
            isPresented: Binding<Bool>
        ) async {
            state = .loading

            guard let odometerValue = Int(odometer) else {
                state = .error
                return
            }

            let vehicleToSave = Vehicle(
                id: vehicle?.id,
                name: name,
                brand: brand,
                model: model,
                year: year,
                licensePlate: licensePlate,
                odometer: odometerValue,
                isDefault: isDefault,
                vehicleTypeId: vehicleTypeId,
                clientId: vehicle?.clientId
            )

            if networkConnectivity.status == .connected {
                await saveRemote(vehicle: vehicleToSave, isPresented: isPresented)
            } else {
                await saveLocal(vehicle: vehicleToSave, isPresented: isPresented)
            }
        }

        private func fetchRemoteVehicleTypes() async {
            guard let remoteTypes = await vehicleTypeRepository.fetchData() else { return }

            do {
                try await swiftDataManager.importData(remoteTypes)
            } catch {
                print(error)
            }
        }

        private func saveRemote(vehicle: Vehicle, isPresented: Binding<Bool>) async {
            if let saved = await repository.save(id: vehicle.id, vehicle: vehicle) {
                if let existingId = saved.id,
                   let existing = try? await swiftDataManager.fetchOne(where: #Predicate<Vehicle> { $0.id == existingId }) {
                    existing.name = saved.name
                    existing.brand = saved.brand
                    existing.model = saved.model
                    existing.year = saved.year
                    existing.licensePlate = saved.licensePlate
                    existing.odometer = saved.odometer
                    existing.isDefault = saved.isDefault
                    existing.vehicleTypeId = saved.vehicleTypeId
                    existing.clientId = saved.clientId
                    existing.synced = true
                    try? await swiftDataManager.save()
                } else if let existing = try? await swiftDataManager.fetchOne(where: #Predicate<Vehicle> { $0.clientId == saved.clientId }) {
                    existing.id = saved.id
                    existing.name = saved.name
                    existing.brand = saved.brand
                    existing.model = saved.model
                    existing.year = saved.year
                    existing.licensePlate = saved.licensePlate
                    existing.odometer = saved.odometer
                    existing.isDefault = saved.isDefault
                    existing.vehicleTypeId = saved.vehicleTypeId
                    existing.synced = true
                    try? await swiftDataManager.save()
                } else {
                    saved.synced = true
                    try? await swiftDataManager.insert(saved)
                }
                state = .successSavedVehicle
                isPresented.wrappedValue = false
            } else {
                await saveLocal(vehicle: vehicle, isPresented: isPresented)
            }
        }

        private func saveLocal(vehicle: Vehicle, isPresented: Binding<Bool>) async {
            do {
                if let id = vehicle.id,
                   let existing = try await swiftDataManager.fetchOne(where: #Predicate<Vehicle> { $0.id == id }) {
                    existing.name = vehicle.name
                    existing.brand = vehicle.brand
                    existing.model = vehicle.model
                    existing.year = vehicle.year
                    existing.licensePlate = vehicle.licensePlate
                    existing.odometer = vehicle.odometer
                    existing.isDefault = vehicle.isDefault
                    existing.vehicleTypeId = vehicle.vehicleTypeId
                    existing.synced = false
                } else {
                    vehicle.synced = false
                    try await swiftDataManager.insert(vehicle)
                }

                try await swiftDataManager.save()
                state = .successSavedVehicle
                isPresented.wrappedValue = false
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
    }
}
