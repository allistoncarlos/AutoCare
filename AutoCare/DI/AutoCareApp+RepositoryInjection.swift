//
//  AutoCareApp+RepositoryInjection.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Factory
import Foundation

extension Container {
    var loginRepository: Factory<LoginRepositoryProtocol> { self { LoginRepository() } }
    
    var vehicleTypeRepository: Factory<VehicleTypeRepositoryProtocol> { self { VehicleTypeRepository() } }
    var vehicleRepository: Factory<VehicleRepositoryProtocol> { self { VehicleRepository() } }
    var vehicleMileageRepository: Factory<VehicleMileageRepositoryProtocol> { self { VehicleMileageRepository() } }
}
