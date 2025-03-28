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
//    @discardableResult func savePlatform(id: String?, platform: Platform) async -> Platform?
}

struct VehicleRepository: VehicleRepositoryProtocol {
    func fetchData() async -> [Vehicle]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> Vehicle? {
        return await dataSource.fetchData(id: id)
    }

//    func savePlatform(id: String?, platform: Platform) async -> Platform? {
//        return await dataSource.savePlatform(id: id, platform: platform)
//    }

    @Injected(\.vehicleDataSource) var dataSource: VehicleDataSourceProtocol
}
