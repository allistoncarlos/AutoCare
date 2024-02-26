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
        }
        
        private func fetchVehicles() async throws {
            if realm == nil {
                self.realm = try await self.openRealm()
                
                updateSubscriptions()
            }
            
            if let realm {
                let vehicles = realm.objects(Vehicle.self)
                
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
        
        private func updateSubscriptions() {
            if let subscriptions = realm?.subscriptions {
                
                updateSubscription(
                    subscriptions: subscriptions,
                    name: "enabled-vehicle-types",
                    type: VehicleType.self
                )
                
                updateSubscription(
                    subscriptions: subscriptions,
                    name: "vehicle",
                    type: Vehicle.self
                )
            }
        }
        
        private func updateSubscription<T: RealmSwiftObject>(
            subscriptions: SyncSubscriptionSet,
            name: String,
            type: T.Type,
            queryBlock: ((Query<T>) -> Query<Bool>)? = nil
        ) {
            subscriptions.update {
                if let existingSubscription = subscriptions.first(named: name) {
                    existingSubscription.updateQuery(toType: type, where: queryBlock)
                } else {
                    let newSubscription = QuerySubscription<T>(name: name, query: queryBlock)
                    subscriptions.append(newSubscription)
                }
            } onComplete: { error in
                if let error {
                    dump(error)
                }
            }
        }
    }
}
