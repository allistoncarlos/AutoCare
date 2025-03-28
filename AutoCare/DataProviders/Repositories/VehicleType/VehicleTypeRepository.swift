//
//  VehicleTypeRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//

import Foundation
import Factory

protocol VehicleTypeRepositoryProtocol {
    func fetchData() async -> [VehicleType]?
}

struct VehicleTypeRepository: VehicleTypeRepositoryProtocol {
    func fetchData() async -> [VehicleType]? {
        return await dataSource.fetchData()
    }
    
    @Injected(\.vehicleTypeDataSource) var dataSource: VehicleTypeDataSourceProtocol
}
