//
//  MileageEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import Combine
import Factory
import FormValidator
import Foundation
import SwiftData
import SwiftUI

extension MileageEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageEditState = .idle
        @Published var vehicleMileage: VehicleMileage?

        var previousMileage: VehicleMileage?

        private let modelContext: ModelContext
        private let localStore: LocalDataStore
        private let vehicleId: String
        private var cancellable = Set<AnyCancellable>()

        @Published var isFormValid = false
        @Published var manager = FormManager(validationType: .immediate)

        @Injected(\.vehicleMileageRepository) private var repository

        @FormField(validator: DateValidator(message: "Informe uma data válida"))
        var date: Date = Date()

        @FormField(validator: NonEmptyValidator(message: "Informe o custo total"))
        var totalCost: String = ""

        var odometer: String?
        var liters: Decimal?
        var fuelCost: String?
        var complete: Bool = true

        @Published var odometerDifference: Int?

        lazy var dateValidation = _date.validation(manager: manager)
        lazy var totalCostValidation = _totalCost.validation(manager: manager)

        init(
            modelContext: ModelContext,
            vehicleMileage: VehicleMileage?,
            vehicleId: String
        ) {
            self.modelContext = modelContext
            self.localStore = LocalDataStore(modelContext: modelContext)
            self.vehicleMileage = vehicleMileage
            self.vehicleId = vehicleId
        }

        func updateOdometerDifference() {
            if let odometer, let intOdometer = Int(odometer), let previousMileage {
                odometerDifference = intOdometer - previousMileage.odometer
            }
        }

        func calculateMileage() -> Decimal? {
            if let odometerDifference, let liters {
                let calculatedMileage = Decimal(odometerDifference) / liters
                return calculatedMileage.roundedDecimal(places: 2)
            }
            return nil
        }

        func fetchPreviousVehicleMileage() async {
            do {
                state = .loading

                let result = try localStore.fetch(
                    where: #Predicate<VehicleMileage> { $0.vehicleId == vehicleId },
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                var lastVehicleMileage: VehicleMileage?

                if let vehicleMileage, let currentId = vehicleMileage.id {
                    if let index = result.firstIndex(where: { $0.id == currentId }), index + 1 < result.count {
                        lastVehicleMileage = result[index + 1]
                    }
                } else {
                    lastVehicleMileage = result.first
                }

                previousMileage = lastVehicleMileage
                state = .successPreviousMileage(lastVehicleMileage)
            } catch {
                print(error)
                state = .error
            }
        }

        func save(isConnected: Bool) async {
            guard manager.triggerValidation() else { return }

            state = .loading

            guard
                let odometer,
                let odometer = Int(odometer),
                let liters,
                let fuelCost,
                let fuelCost = Decimal(string: fuelCost),
                let totalCostValue = Decimal(string: totalCost)
            else {
                state = .error
                return
            }

            let calculatedMileage = calculateMileage() ?? 0
            let mileage = vehicleMileage ?? VehicleMileage(
                id: nil,
                date: date,
                totalCost: totalCostValue,
                odometer: odometer,
                odometerDifference: odometerDifference ?? 0,
                liters: liters,
                fuelCost: fuelCost,
                calculatedMileage: calculatedMileage,
                complete: complete,
                vehicleId: vehicleId
            )

            if isConnected {
                await saveRemote(id: mileage.id, vehicleMileage: mileage)
            } else {
                saveLocal(id: mileage.id, vehicleMileage: mileage)
            }
        }

        private func saveRemote(id: String?, vehicleMileage: VehicleMileage) async {
            if let saved = await repository.save(id: id, vehicleMileage: vehicleMileage) {
                if let existingId = saved.id,
                   let existing = try? localStore.fetchOne(where: #Predicate<VehicleMileage> { $0.id == existingId }) {
                    existing.date = saved.date
                    existing.totalCost = saved.totalCost
                    existing.odometer = saved.odometer
                    existing.odometerDifference = saved.odometerDifference
                    existing.liters = saved.liters
                    existing.fuelCost = saved.fuelCost
                    existing.calculatedMileage = saved.calculatedMileage
                    existing.complete = saved.complete
                    existing.synced = true
                    try? localStore.save()
                } else {
                    saved.synced = true
                    try? localStore.insert(saved)
                }
                state = .successSave
            } else {
                saveLocal(id: id, vehicleMileage: vehicleMileage)
            }
        }

        private func saveLocal(id: String?, vehicleMileage: VehicleMileage) {
            do {
                if let id {
                    try update(id: id, vehicleMileage: vehicleMileage)
                } else {
                    try insert(vehicleMileage: vehicleMileage)
                }
                state = .successSave
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }

        private func update(id: String, vehicleMileage: VehicleMileage) throws {
            guard let existing = try localStore.fetchOne(where: #Predicate<VehicleMileage> { $0.id == id }) else {
                state = .error
                return
            }

            existing.date = vehicleMileage.date
            existing.totalCost = vehicleMileage.totalCost
            existing.odometer = vehicleMileage.odometer
            existing.odometerDifference = vehicleMileage.odometerDifference
            existing.liters = vehicleMileage.liters
            existing.fuelCost = vehicleMileage.fuelCost
            existing.calculatedMileage = vehicleMileage.calculatedMileage
            existing.complete = vehicleMileage.complete
            existing.synced = false
            try localStore.save()
            state = .successSave
        }

        private func insert(vehicleMileage: VehicleMileage) throws {
            vehicleMileage.synced = false
            try localStore.insert(vehicleMileage)
            state = .successSave
        }
    }
}

#if os(iOS)
extension MileageEditView.ViewModel {
    func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        MileagesRouter.goBackToMileages(navigationPath: navigationPath)
    }
}
#endif
