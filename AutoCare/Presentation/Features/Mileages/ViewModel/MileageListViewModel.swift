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
            
            await login()
        }
        
        private func login() async {
            state = .loading
            
            let credentials = Credentials.emailPassword(email: "", password: "")
            _ = try? await app?.login(credentials: credentials)
            
            try? await fetchVehicles()
        }
        
        private func fetchVehicles() async throws {
            if realm == nil {
                self.realm = try await self.openRealm()
            }
            
            if let realm {
                let vehicles = realm.objects(Vehicle.self)
                
                state = vehicles.isEmpty ? .newVehicle : .success
            }
        }
        
        private func openRealm() async throws -> Realm {
            if let app {
                if let user = app.currentUser {
                    let config = user.flexibleSyncConfiguration(
                        clientResetMode: .recoverUnsyncedChanges(),
                        initialSubscriptions: { subs in
                            if let _ = subs.first(named: "enabled-vehicle-types"),
                               let _ = subs.first(named: "vehicles") {
                                return
                            } else {
                                subs.append(QuerySubscription<VehicleType>(name: "enabled-vehicle-types"))
                                subs.append(QuerySubscription<Vehicle>(name: "vehicles"))
                            }
                        },
                        rerunOnOpen: true
                    )
                    
                    let realm = try await Realm(configuration: config, downloadBeforeOpen: .always)
                    return realm
                }
            }
            
            throw AppError(_nsError: NSError())
        }
    }
}
