//
//  VehicleRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation
import Factory

protocol VehicleRepositoryProtocol {
    func fetchData() async -> [VehicleData]?
    func fetchData(id: String) async -> VehicleData?
}

struct VehicleRepository: VehicleRepositoryProtocol {
    func fetchData() async -> [VehicleData]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> VehicleData? {
        return await dataSource.fetchData(id: id)
    }

    @Injected(\.vehicleDataSource) var dataSource: VehicleDataSourceProtocol
}
