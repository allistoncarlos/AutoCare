//
//  MileageListState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/10/23.
//

import Foundation

enum MileageListState: Equatable {
    case idle
    case loading
    case error
    case newVehicle
    case success
}
