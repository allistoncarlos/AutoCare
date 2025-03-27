//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI
import Combine

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: ServiceListState = .idle
        @Published var vehicleServices = [VehicleService]()
        @Published var selectedVehicle: VehicleData
        
        // MARK: - Properties
        var realm: Realm
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        init(realm: Realm, selectedVehicle: VehicleData) {
            self.realm = realm
            self.selectedVehicle = selectedVehicle
        }
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleServices(vehicleServices):
                        self?.vehicleServices = vehicleServices
                    default:
                        break
                    }
                }.store(in: &cancellable)
            
            await fetchVehicleServices()
        }
        
        func fetchVehicleServices() async {
            state = .loading
            
            if let app, let user = app.currentUser {
                let vehicleServices = try! await realm.objects(VehicleService.self)
                    .where {
                        $0.owner_id == user.id
                    }
                    .subscribe(
                        name: "vehicle-services",
                        waitForSync: .onCreation
                    )
                
                var vehicleServicesArray = Array(vehicleServices)
                vehicleServicesArray = vehicleServicesArray.sorted(by: {
                    $0.date.compare($1.date) == .orderedDescending
                })
                
                state = .successVehicleServices(vehicleServicesArray)
            }
        }
    }
}
