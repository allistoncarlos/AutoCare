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

        private let vehicleId: String

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
            state = .loading

            guard let mileages = await repository.fetchData(vehicleId: vehicleId) else {
                state = .error
                return
            }

            let sorted = mileages.sorted { $0.date > $1.date }
            var lastVehicleMileage: VehicleMileage?

            if let vehicleMileage, let currentId = vehicleMileage.id {
                if let index = sorted.firstIndex(where: { $0.id == currentId }), index + 1 < sorted.count {
                    lastVehicleMileage = sorted[index + 1]
                }
            } else {
                lastVehicleMileage = sorted.first
            }

            previousMileage = lastVehicleMileage
            state = .successPreviousMileage(lastVehicleMileage)
        }

        func save() async {
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

            if await repository.save(id: mileage.id, vehicleMileage: mileage) != nil {
                state = .successSave
            } else {
                state = .error
            }
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
