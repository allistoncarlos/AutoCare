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

        @Injected(\.vehicleRepository) private var repository
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository

        init(modelContext: ModelContext, vehicleId: String?) {
            self.vehicleId = vehicleId
        }

        func fetchData() async {
            state = .loading

            vehicleTypes = await vehicleTypeRepository.fetchData() ?? []
            state = .successVehicleTypes(vehicleTypes)

            if let vehicleId {
                await fetchVehicle(vehicleId: vehicleId)
            }
        }

        func fetchVehicle(vehicleId: String) async {
            state = .loading

            if let result = await repository.fetchData(id: vehicleId) {
                vehicle = result
                state = .successVehicle(result)
            } else {
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
                vehicleTypeId: vehicleTypeId
            )

            if await repository.save(id: vehicleToSave.id, vehicle: vehicleToSave) != nil {
                state = .successSavedVehicle
                isPresented.wrappedValue = false
            } else {
                state = .error
            }
        }
    }
}
