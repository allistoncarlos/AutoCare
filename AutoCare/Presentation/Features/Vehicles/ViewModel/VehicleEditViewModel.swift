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
        
        private var cancellable = Set<AnyCancellable>()
        
        var configuration: Realm.Configuration
        var vehicleTypes: [VehicleType]?
        
        init(
            configuration: Realm.Configuration,
            vehicle: Vehicle = Vehicle()
        ) {
            self.configuration = configuration
            self.vehicle = vehicle
            
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
        }
        
        func fetchVehicleTypes() async {
            state = .loading
            
            do {
                let realm = try await Realm(
                    configuration: configuration,
                    downloadBeforeOpen: .always
                )
                
                let vehicleTypes = Array(realm.objects(VehicleType.self)).sorted(by: { $0.name < $1.name })
                
                state = .successVehicleTypes(vehicleTypes)
            } catch {
                print(error)
                state = .error
            }
        }
        
        func save() async {
            let vehicleType = vehicleTypes?.first { $0.name == selectedVehicleType }
        }
    }
}
