//
//  VehicleEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Foundation
import RealmSwift
import Realm
import Combine

extension VehicleEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: VehicleEditState = .idle
        @Published var selectedVehicleType = ""
        @Published var vehicle: Vehicle
        @Published var isFormValid = false
        
        private var cancellable = Set<AnyCancellable>()
        
        var vehicleTypes: [VehicleType]?
        var realm: Realm
        
        init(
            vehicle: Vehicle = Vehicle(),
            realm: Realm
        ) {
            self.vehicle = vehicle
            self.realm = realm
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleTypes(vehicleTypes):
                        self?.vehicleTypes = vehicleTypes
                    default:
                        break
                    }
                }.store(in: &cancellable)
            
            $vehicle
                .receive(on: RunLoop.main)
                .sink { [weak self] vehicle in
                    guard let self else { return }
                    
                    self.isFormValid = self.handleForm()
                }.store(in: &cancellable)
        }
        
        func fetchVehicleTypes() async {
            state = .loading

            let vehicleTypes = Array(realm.objects(VehicleType.self)).sorted(by: { $0.name < $1.name })

            state = .successVehicleTypes(vehicleTypes)
        }
        
        func save() async {
            let vehicleType = vehicleTypes?.first { $0.name == selectedVehicleType }
        }
        
        private func handleForm() -> Bool {
            if vehicle.vehicleType == nil {
                return false
            }
            
            if vehicle.name.isEmpty {
                return false
            }
            
            if vehicle.brand.isEmpty {
                return false
            }
            
            if vehicle.model.isEmpty {
                return false
            }
            
            if vehicle.licensePlate.isEmpty {
                return false
            }
            
            return true
        }
    }
}
