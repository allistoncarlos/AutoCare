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

extension MileageEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageEditState = .idle
        @Published var vehicleMileage: VehicleMileage?
        
        var lastVehicleMileage: VehicleMileage?
        
        private var cancellable = Set<AnyCancellable>()
        private var realm: Realm
        private var vehicleId: ObjectId
        
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
                    case let .successLastVehicleMileage(lastVehicleMileage):
                        self?.lastVehicleMileage = lastVehicleMileage
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
                
                if let lastVehicleMileage {
                    print(lastVehicleMileage)
                }
                
                state = .successLastVehicleMileage(lastVehicleMileage)
            } catch {
                print(error)
                state = .error
            }
        }
    }
}
