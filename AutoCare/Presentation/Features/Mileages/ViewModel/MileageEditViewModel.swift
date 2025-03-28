//
//  MileageEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import Foundation
import SwiftUI
import Combine
import FormValidator

extension MileageEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageEditState = .idle
        @Published var vehicleMileage: VehicleMileage?
        
        var previousMileage: VehicleMileage?
        
        private var cancellable = Set<AnyCancellable>()
        private var vehicleId: String
        
        @Published var isFormValid = false
        
        @Published var manager = FormManager(validationType: .immediate)
        
        // MARK: - Form Fields
        @FormField(validator: DateValidator(message: "Informe uma data válida"))
        var date: Date = Date()
        
        @FormField(validator: NonEmptyValidator(message: "Informe o custo total"))
        var totalCost: String = ""
        
        var odometer: String?
        var liters: Decimal?
        var fuelCost: String?
        var complete: Bool = true
        
        @Published var odometerDifference: Int?
        
        // MARK: - Validations
        lazy var dateValidation = _date.validation(manager: manager)
        lazy var totalCostValidation = _totalCost.validation(manager: manager)
        
        init(
            vehicleMileage: VehicleMileage?,
            vehicleId: String
        ) {
            self.vehicleMileage = vehicleMileage
            self.vehicleId = vehicleId
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successPreviousMileage(previousMileage):
                        self?.previousMileage = previousMileage
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        func updateOdometerDifference() {
            if let odometer, let intOdometer = Int(odometer), let previousMileage {
                self.odometerDifference = intOdometer - previousMileage.odometer
            }
        }
        
        func calculateMileage() -> Decimal? {
            // Diferença de quilometragem, pela litragem
            if let odometerDifference = odometerDifference, let liters = liters {
                let calculatedMileage = Decimal(odometerDifference) / liters
                let roundedMileage = calculatedMileage.roundedDecimal(places: 2)
                return roundedMileage
            }
            
            return nil
        }
        
        func fetchPreviousVehicleMileage() async {
//            do {
//                guard let userId = AutoCareApp.app.currentUser?.id else {
//                    throw RLMError(.fail)
//                }
//                
//                state = .loading
//                
//                let vehicleMileages = realm.objects(VehicleMileage.self)
//                
//                var lastVehicleMileage: VehicleMileage? = nil
//                
//                if let vehicleMileage {
//                    let index = vehicleMileages.lastIndex(where: { $0._id == vehicleMileage._id })
//
//                    if let index, index < vehicleMileages.count - 1 {
//                        lastVehicleMileage = vehicleMileages[index + 1]
//                    }
//                } else {
//                    lastVehicleMileage = vehicleMileages
//                        .where {
//                            $0.owner_id == userId &&
//                            $0.vehicle_id == vehicleId
//                        }
//                        .sorted { $0.date > $1.date }
//                        .first
//                }
//                
//                state = .successPreviousMileage(lastVehicleMileage)
//            } catch {
//                print(error)
//                state = .error
//            }
        }
        
        func save() async {
//            if manager.triggerValidation() {
//                state = .loading
//                
//                do {
//                    if let calculatedMileage = calculateMileage() {
//                        let resultVehicleMileage = vehicleMileage ?? VehicleMileage()
//                        
//                        resultVehicleMileage.owner_id = userId
////                        resultVehicleMileage.vehicle_id = vehicleId
//                        resultVehicleMileage.date = date
//                        
//                        if let odometer, let odometer = Int(odometer) {
//                            resultVehicleMileage.odometer = odometer
//                        }
//                        
//                        if let odometerDifference {
//                            resultVehicleMileage.odometerDifference = odometerDifference
//                        }
//                        
//                        if let liters {
//                            resultVehicleMileage.liters = Decimal128(value: liters)
//                        }
//                        
//                        if let fuelCost {
//                            resultVehicleMileage.fuelCost = Decimal128(value: fuelCost)
//                        }
//                        
//                        resultVehicleMileage.totalCost = Decimal128(value: totalCost)
//                        resultVehicleMileage.calculatedMileage = calculatedMileage
//    
//                        try await realm.asyncWrite {
//                            realm.add(resultVehicleMileage)
//                        }
//                        
//                        state = .successSave
//                    } else {
//                        state = .error
//                    }
//                } catch {
//                    print(error)
//                    state = .error
//                }
//            }
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
