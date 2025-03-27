//
//  VehicleListState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation

enum VehicleListState: Equatable {
    case idle
    case loading
    case error
    case successVehicles([VehicleData])
}
