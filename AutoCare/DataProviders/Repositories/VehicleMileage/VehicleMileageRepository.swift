//
//  VehicleMileageRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Foundation
import Factory

protocol VehicleMileageRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]?
    func fetchData(vehicleId: String, id: String) async -> VehicleMileage?
    @discardableResult func save(id: String?, vehicleMileage: VehicleMileage) async -> VehicleMileage?
}

struct VehicleMileageRepository: VehicleMileageRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]? {
        return await dataSource.fetchData(vehicleId: vehicleId)
    }

    func fetchData(vehicleId: String,id: String) async -> VehicleMileage? {
        return await dataSource.fetchData(vehicleId: vehicleId, id: id)
    }

    func save(id: String?, vehicleMileage: VehicleMileage) async -> VehicleMileage? {
        return await dataSource.save(id: id, vehicleMileage: vehicleMileage)
    }

    @Injected(\.vehicleMileageDataSource) var dataSource: VehicleMileageDataSourceProtocol
}
