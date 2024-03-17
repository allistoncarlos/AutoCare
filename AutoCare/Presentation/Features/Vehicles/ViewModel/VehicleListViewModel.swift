//
//  VehicleListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import RealmSwift
import Realm
import Combine
import FormValidator

extension VehicleListView {
    @MainActor
    class ViewModel: ObservableObject {
        // MARK: - Published properties
        @Published var state: VehicleListState = .idle
        @Published var vehicles = [Vehicle]()
        
        // MARK: - Properties
        private var cancellable = Set<AnyCancellable>()
        private var realm: Realm
        
        // MARK: - Init
        init(realm: Realm) {
            self.realm = realm
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicles(vehicles):
                        self?.vehicles = vehicles
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        // MARK: - Func
        func fetchVehicles() async {
            state = .loading
            
            let vehicles = Array(realm.objects(Vehicle.self))

            state = .successVehicles(Array(vehicles))
        }
    }
}
