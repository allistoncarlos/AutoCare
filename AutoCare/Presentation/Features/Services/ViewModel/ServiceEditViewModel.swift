//
//  ServiceEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 15/08/26.
//

import Combine
import Factory
import FormValidator
import Foundation
import SwiftUI

extension ServiceEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: ServiceEditState = .idle
        @Published var vehicleService: VehicleService?

        private let serviceClientId: String?
        private let vehicleId: String

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.vehicleServiceRepository) private var repository

        @Published var isFormValid = false
        @Published var manager = FormManager(validationType: .immediate)

        @FormField(validator: DateValidator(message: "Informe uma data válida"))
        var date: Date = Date()

        @FormField(validator: NonEmptyValidator(message: "Informe o custo total"))
        var totalCost: String = "0"

        @Published var type: VehicleServiceType = .wheelsAndTyres
        @Published var subtype: VehicleServiceSubtype = .calibrate
        @Published var comment: String = ""

        var odometer: String? = "0"

        lazy var dateValidation = _date.validation(manager: manager)
        lazy var totalCostValidation = _totalCost.validation(manager: manager)

        var isEditing: Bool { serviceClientId != nil }

        var taskId: String { serviceClientId ?? "new" }

        init(serviceClientId: String?, vehicleId: String) {
            self.serviceClientId = serviceClientId
            self.vehicleId = vehicleId
        }

        struct FormSnapshot {
            let totalCostValue: Int
            let odometerValue: Int
        }

        func formSnapshotForExistingService() -> FormSnapshot? {
            guard let service = vehicleService else { return nil }

            return FormSnapshot(
                totalCostValue: Self.currencyFieldValue(from: service.totalCost),
                odometerValue: service.odometer * 100
            )
        }

        func reloadExistingService() async {
            guard let serviceClientId, !serviceClientId.isEmpty else { return }

            guard
                let fresh: VehicleService = try? await swiftDataManager.fetchOne(
                    where: #Predicate<VehicleService> { $0.clientId == serviceClientId }
                )
            else {
                return
            }

            vehicleService = fresh
            populateFromExistingService()
        }

        func ensureValidSubtype() {
            if !type.subtypes.contains(subtype), let firstSubtype = type.subtypes.first {
                subtype = firstSubtype
            }
        }

        func save() async {
            guard manager.triggerValidation() else { return }

            state = .loading

            guard
                let odometer,
                let totalCostValue = Decimal(string: totalCost)
            else {
                state = .error
                return
            }

            let odometerValue: Int
            if let parsed = Int(odometer) {
                odometerValue = parsed
            } else if let parsed = Decimal(string: odometer) {
                odometerValue = NSDecimalNumber(decimal: parsed).intValue
            } else {
                state = .error
                return
            }

            if let vehicleService {
                vehicleService.date = date
                vehicleService.odometer = odometerValue
                vehicleService.type = type
                vehicleService.subtype = subtype
                vehicleService.totalCost = totalCostValue
                vehicleService.comment = comment
                vehicleService.synced = false

                if await repository.save(vehicleService: vehicleService) != nil {
                    state = .successSave
                } else {
                    state = .error
                }
                return
            }

            let service = VehicleService(
                id: nil,
                date: date,
                odometer: odometerValue,
                type: type,
                subtype: subtype,
                totalCost: totalCostValue,
                comment: comment,
                vehicle_id: vehicleId
            )

            if await repository.save(vehicleService: service) != nil {
                state = .successSave
            } else {
                state = .error
            }
        }

        private func populateFromExistingService() {
            guard let service = vehicleService else { return }

            date = service.date
            type = service.type
            subtype = service.subtype
            totalCost = NSDecimalNumber(decimal: service.totalCost).stringValue
            odometer = "\(service.odometer)"
            comment = service.comment
            ensureValidSubtype()
        }

        private static func currencyFieldValue(from decimal: Decimal) -> Int {
            NSDecimalNumber(decimal: decimal * 100).intValue
        }
    }
}

#if os(iOS)
extension ServiceEditView.ViewModel {
    func goBackToServices(navigationPath: Binding<NavigationPath>) {
        ServicesRouter.goBackToServices(navigationPath: navigationPath)
    }
}
#endif
