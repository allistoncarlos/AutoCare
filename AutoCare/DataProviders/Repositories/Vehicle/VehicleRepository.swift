//
//  VehicleRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation
import Factory

protocol VehicleRepositoryProtocol {
    func fetchData() async -> [Vehicle]?
    func fetchData(id: String) async -> Vehicle?
    @discardableResult func save(id: String?, vehicle: Vehicle) async -> Vehicle?
}

struct VehicleRepository: VehicleRepositoryProtocol {
    func fetchData() async -> [Vehicle]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> Vehicle? {
        return await dataSource.fetchData(id: id)
    }

    func save(id: String?, vehicle: Vehicle) async -> Vehicle? {
        return await dataSource.save(id: id, vehicle: vehicle)
    }

    @Injected(\.vehicleDataSource) var dataSource: VehicleDataSourceProtocol
}
