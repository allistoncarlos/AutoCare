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
        var app: App?
        var configuration: Realm.Configuration?
        
        @Published var state: MileageListState = .idle
        
        func setup(app: App) async {
            self.app = app
            
            await anonymousLogin()
        }
        
        private func anonymousLogin() async {
            state = .loading
            
            do {
                if let app {
                    let user = try await app.login(
                        credentials: .anonymous
                    )
                    
                    configuration = user.flexibleSyncConfiguration(
                        clientResetMode: .recoverUnsyncedChanges(),
                        initialSubscriptions: { subs in
                            subs.append(QuerySubscription<VehicleType>(name: "enabled-vehicle-types") {
                                $0.enabled
                            })
                        }
                    )
                        
                    if let configuration {
                        let realm = try await Realm(
                            configuration: configuration,
                            downloadBeforeOpen: .always
                        )
                        
                        let vehicles = realm.objects(Vehicle.self)
                        
                        state = vehicles.isEmpty ? .newVehicle : .success
                    }
                }
            } catch {
                print(error)
                state = .error
            }
        }
    }
}
