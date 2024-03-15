//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Foundation
import RealmSwift
import Realm

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        
        private var app: App?
        var realm: Realm? = nil
        
        func setup(app: App) async {
            self.app = app
            
            await fetchVehicles()
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
                
                state = vehicles.isEmpty ? .newVehicle : .success
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
