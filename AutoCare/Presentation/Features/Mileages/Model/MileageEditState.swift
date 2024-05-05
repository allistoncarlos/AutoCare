//
//  MileageEditState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/05/24.
//

import Foundation

enum MileageEditState: Equatable {
    case idle
    case loading
    case error
    case successLastVehicleMileage(VehicleMileage?)
    case successSave
}
