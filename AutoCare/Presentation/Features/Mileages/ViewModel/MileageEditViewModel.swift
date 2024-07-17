//
//  MileageEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import Foundation
import RealmSwift
import Realm
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
        private var realm: Realm
        private var vehicleId: ObjectId
        
        @Published var isFormValid = false
        
        @Published var manager = FormManager(validationType: .immediate)
        
        // MARK: - Form Fields
        @FormField(validator: DateValidator(message: "Informe uma data válida"))
        var date: Date = Date()
        
        @FormField(validator: NonEmptyValidator(message: "Informe o custo total"))
        var totalCost: String = ""
        
        var odometer: String?
        var odometerDifference: String?
        var liters: String?
        var fuelCost: String?
        var complete: Bool = true
        
        // MARK: - Validations
        lazy var dateValidation = _date.validation(manager: manager)
        lazy var totalCostValidation = _totalCost.validation(manager: manager)
        
        init(
            realm: Realm,
            vehicleMileage: VehicleMileage?,
            vehicleId: ObjectId
        ) {
            self.realm = realm
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
        
        func fetchLastVehicleMileage() async {
            do {
                guard let userId = AutoCareApp.app.currentUser?.id else {
                    throw RLMError(.fail)
                }
                
                state = .loading
                
                let vehicleMileages = realm.objects(VehicleMileage.self)
                
                var lastVehicleMileage: VehicleMileage? = nil
                
                if let vehicleMileage {
                    let index = vehicleMileages.lastIndex(where: { $0._id == vehicleMileage._id })

                    if let index, index < vehicleMileages.count - 1 {
                        lastVehicleMileage = vehicleMileages[index + 1]
                    }
                } else {
                    lastVehicleMileage = vehicleMileages
                        .where {
                            $0.owner_id == userId &&
                            $0.vehicle_id == vehicleId
                        }.first
                }
                
                state = .successPreviousMileage(lastVehicleMileage)
            } catch {
                print(error)
                state = .error
            }
        }
        
        func save() async {
            state = .loading
            
            if manager.triggerValidation() {
                do {
                    guard let userId = AutoCareApp.app.currentUser?.id else {
                        throw RLMError(.fail)
                    }
                    
//                    vehicle.vehicleType = vehicleTypes.first { $0.name == selectedVehicleType }
//                    vehicle.owner_id = userId
//                    vehicle.name = self.name
//                    vehicle.brand = self.brand
//                    vehicle.model = self.model
//                    vehicle.year = self.year
//                    vehicle.licensePlate = self.licensePlate
//                    vehicle.odometer = odometer
//                    
//                    try await realm.asyncWrite {
//                        realm.add(vehicle)
//                    }
                    
                    state = .successSave
                } catch {
                    print(error)
                    state = .error
                }
            }
        }
    }
}
