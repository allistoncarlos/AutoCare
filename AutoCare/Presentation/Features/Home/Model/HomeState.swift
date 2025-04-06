//
//  HomeState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation

enum HomeState: Equatable, Sendable {
    case idle
    case loading
    case error
    case newVehicle
    case successVehicle([Vehicle])
}
