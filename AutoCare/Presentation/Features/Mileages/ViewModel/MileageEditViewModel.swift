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
import SwiftUI

extension MileageEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageEditState = .idle
        @Published var vehicleMileage: VehicleMileage?

        var previousMileage: VehicleMileage?

        private let mileageClientId: String?
        private let vehicleId: String
        private var cancellable = Set<AnyCancellable>()

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.vehicleMileageRepository) private var repository

        @Published var isFormValid = false
        @Published var manager = FormManager(validationType: .immediate)

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

        var isEditing: Bool { mileageClientId != nil }

        var taskId: String { mileageClientId ?? "new" }

        init(mileageClientId: String?, vehicleId: String) {
            self.mileageClientId = mileageClientId
            self.vehicleId = vehicleId
        }

        struct FormSnapshot {
            let totalCostValue: Int
            let fuelCostValue: Int
            let odometerValue: Int
            let litersValue: Int
            let isComplete: Bool
        }

        func formSnapshotForExistingMileage() -> FormSnapshot? {
            guard let mileage = vehicleMileage else { return nil }

            return FormSnapshot(
                totalCostValue: Self.currencyFieldValue(from: mileage.totalCost),
                fuelCostValue: Self.currencyFieldValue(from: mileage.fuelCost),
                odometerValue: mileage.odometer * 100,
                litersValue: Self.currencyFieldValue(from: mileage.liters),
                isComplete: mileage.complete
            )
        }

        private func populateFromExistingMileage() {
            guard let mileage = vehicleMileage else { return }

            date = mileage.date
            totalCost = NSDecimalNumber(decimal: mileage.totalCost).stringValue
            fuelCost = NSDecimalNumber(decimal: mileage.fuelCost).stringValue
            odometer = "\(mileage.odometer)"
            liters = mileage.liters
            complete = mileage.complete
            odometerDifference = mileage.odometerDifference
        }

        private static func currencyFieldValue(from decimal: Decimal) -> Int {
            NSDecimalNumber(decimal: decimal * 100).intValue
        }

        private func mileageIdentity(_ mileage: VehicleMileage) -> String {
            mileage.id ?? mileage.clientId
        }

        func reloadExistingMileage() async {
            guard let mileageClientId, !mileageClientId.isEmpty else { return }

            guard
                let fresh: VehicleMileage = try? await swiftDataManager.fetchOne(
                    where: #Predicate<VehicleMileage> { $0.clientId == mileageClientId }
                )
            else {
                return
            }

            vehicleMileage = fresh
            populateFromExistingMileage()
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
                if !isEditing {
                    state = .loading
                }

                let result = try await swiftDataManager.fetch(
                    where: #Predicate<VehicleMileage> { $0.vehicleId == vehicleId },
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                var lastVehicleMileage: VehicleMileage?

                if let vehicleMileage {
                    let currentIdentity = mileageIdentity(vehicleMileage)
                    if let index = result.firstIndex(where: { mileageIdentity($0) == currentIdentity }),
                       index + 1 < result.count {
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

            if let vehicleMileage {
                vehicleMileage.date = date
                vehicleMileage.totalCost = totalCostValue
                vehicleMileage.odometer = odometer
                vehicleMileage.odometerDifference = odometerDifference ?? 0
                vehicleMileage.liters = liters
                vehicleMileage.fuelCost = fuelCost
                vehicleMileage.calculatedMileage = calculatedMileage
                vehicleMileage.complete = complete
                vehicleMileage.synced = false

                if await repository.save(vehicleMileage: vehicleMileage) != nil {
                    state = .successSave
                } else {
                    state = .error
                }
                return
            }

            let mileage = VehicleMileage(
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

            if await repository.save(vehicleMileage: mileage) != nil {
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
