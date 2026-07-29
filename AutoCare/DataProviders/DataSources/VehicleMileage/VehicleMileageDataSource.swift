//
//  VehicleMileageDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Foundation

protocol VehicleMileageDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileageResponse]?
    func fetchData(vehicleId: String, id: String) async -> VehicleMileageResponse?
    func save(vehicleMileage: VehicleMileage) async throws -> VehicleMileageResponse?
}

class VehicleMileageDataSource: VehicleMileageDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileageResponse]? {
        await NetworkManager.shared.performRequest(
            responseType: [VehicleMileageResponse].self,
            endpoint: .vehicleMileages(vehicleId: vehicleId)
        )
    }

    func fetchData(vehicleId: String, id: String) async -> VehicleMileageResponse? {
        await NetworkManager.shared.performRequest(
            responseType: VehicleMileageResponse.self,
            endpoint: .vehicleMileage(id: id)
        )
    }

    func save(vehicleMileage: VehicleMileage) async throws -> VehicleMileageResponse? {
        let request = vehicleMileage.toRequest()
        return await NetworkManager.shared.performRequest(
            responseType: VehicleMileageResponse.self,
            endpoint: .saveVehicleMileage(data: request, serverId: vehicleMileage.id)
        )
    }
}
