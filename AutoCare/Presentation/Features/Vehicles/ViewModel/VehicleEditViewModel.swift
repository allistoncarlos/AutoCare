//
//  VehicleEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension VehicleEditView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var state: VehicleEditState = .idle
        @Published private(set) var vehicleTypes: [VehicleType] = []
        @Published private(set) var vehicle: Vehicle?

        private let vehicleId: String?

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.vehicleRepository) private var repository
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository

        init(vehicleId: String?) {
            self.vehicleId = vehicleId
        }

        func fetchData() async {
            state = .loading

            await fetchRemoteVehicleTypes()

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

            if let vehicle {
                vehicle.name = name
                vehicle.brand = brand
                vehicle.model = model
                vehicle.year = year
                vehicle.licensePlate = licensePlate
                vehicle.odometer = odometerValue
                vehicle.isDefault = isDefault
                vehicle.vehicleTypeId = vehicleTypeId
                vehicle.synced = false

                if await repository.save(vehicle: vehicle) != nil {
                    state = .successSavedVehicle
                    isPresented.wrappedValue = false
                } else {
                    state = .error
                }
                return
            }

            let vehicleToSave = Vehicle(
                id: nil,
                name: name,
                brand: brand,
                model: model,
                year: year,
                licensePlate: licensePlate,
                odometer: odometerValue,
                isDefault: isDefault,
                vehicleTypeId: vehicleTypeId
            )

            if await repository.save(vehicle: vehicleToSave) != nil {
                state = .successSavedVehicle
                isPresented.wrappedValue = false
            } else {
                state = .error
            }
        }

        private func fetchRemoteVehicleTypes() async {
            guard KeychainDataSource.hasValidToken() else { return }
            guard let remoteTypes = await vehicleTypeRepository.fetchData() else { return }

            do {
                try await swiftDataManager.importData(remoteTypes)
            } catch {
                print(error)
            }
        }
    }
}
