//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        
        private var app: RealmSwift.App?
        var realm: Realm? = nil
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
            await fetchVehicles()
        }
        
        // MARK: - Router
        func showEditVehicleView(
            realm: Realm,
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            return MileagesRouter.makeEditVehicleView(
                realm: realm,
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }
        
        private func fetchVehicles() async {
            state = .loading
            
            if realm == nil {
                do {
                    self.realm = try await self.openRealm()
                } catch {
                    state = .error
                }
            }
            
            if let realm, let app, let user = app.currentUser {
                let vehicles = try! await realm.objects(Vehicle.self)
                    .where { $0.owner_id == user.id }
                    .subscribe(
                        name: "vehicle",
                        waitForSync: .onCreation
                    )
                
                _ = try! await realm.objects(VehicleType.self)
                    .where { $0.enabled }
                    .subscribe(
                        name: "enabled-vehicle-types",
                        waitForSync: .onCreation
                    )
                
                if vehicles.isEmpty {
                    state = .newVehicle
                } else {
                    // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
                    
                    if let vehicle = vehicles.first {
                        let vehicleMileages = try! await realm.objects(VehicleMileage.self)
                            .where {
                                $0.owner_id == user.id &&
                                $0.vehicle_id == vehicle._id
                            }
                            .subscribe(
                                name: "vehicle-mileages",
                                waitForSync: .onCreation
                            )
                        
                        print(Array(vehicleMileages))
                        print(vehicleMileages.count)
                        
                        state = .successVehicleMileages(Array(vehicleMileages))
                    }
                }
            }
        }
        
        private func fetchVehicleMileages() {
            if let realm {
                state = .loading
                
                let vehicleMileages = Array(realm.objects(VehicleMileage.self))
                
                state = .successVehicleMileages(Array(vehicleMileages))
            }
        }
        
        
        private func openRealm() async throws -> Realm {
            guard let app = app, let user = app.currentUser else {
                throw AppError(_nsError: NSError())
            }
            
            let config = user.flexibleSyncConfiguration()
            let realm = try await Realm(configuration: config)
            
            return realm
        }
    }
}
