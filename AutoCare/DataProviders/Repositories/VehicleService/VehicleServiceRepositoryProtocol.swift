//
//  VehicleServiceRepositoryProtocol.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation
import Factory

protocol VehicleServiceRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]?
    func fetchData(vehicleId: String, id: String) async -> VehicleService?
    @discardableResult func save(id: String?, vehicleService: VehicleService) async -> VehicleService?
}

struct VehicleServiceRepository: VehicleServiceRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]? {
        return await dataSource.fetchData(vehicleId: vehicleId)
    }

    func fetchData(vehicleId: String, id: String) async -> VehicleService? {
        return await dataSource.fetchData(vehicleId: vehicleId, id: id)
    }

    func save(id: String?, vehicleService: VehicleService) async -> VehicleService? {
        return await dataSource.save(id: id, vehicleService: vehicleService)
    }

    @Injected(\.vehicleServiceDataSource) var dataSource: VehicleServiceDataSourceProtocol
}

