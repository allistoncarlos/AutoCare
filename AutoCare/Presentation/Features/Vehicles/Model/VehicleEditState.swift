//
//  VehicleEditState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Foundation

enum VehicleEditState: Equatable {
    case idle
    case loading
    case error
    case successVehicleTypes([VehicleType])
    case successVehicle(Vehicle)
    case successSavedVehicle
}
