//
//  ServiceListState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation

enum ServiceListState: Equatable {
    case idle
    case loading
    case error
    case newVehicle
    case successVehicleServices([VehicleService])
    
    static func == (lhs: ServiceListState, rhs: ServiceListState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.error, .error),
             (.newVehicle, .newVehicle):
            return true
        case (.successVehicleServices(let lhsServices), .successVehicleServices(let rhsServices)):
            return lhsServices.map { $0.clientId } == rhsServices.map { $0.clientId }
        default:
            return false
        }
    }
}
