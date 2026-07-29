//
//  VehicleServiceDataSourceProtocol.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation

protocol VehicleServiceDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleServiceResponse]?
    func fetchData(vehicleId: String, id: String) async -> VehicleServiceResponse?
    func save(vehicleService: VehicleService) async throws -> VehicleServiceResponse?
}

class VehicleServiceDataSource: VehicleServiceDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleServiceResponse]? {
        await NetworkManager.shared.performRequest(
            responseType: [VehicleServiceResponse].self,
            endpoint: .vehicleServices(vehicleId: vehicleId)
        )
    }

    func fetchData(vehicleId: String, id: String) async -> VehicleServiceResponse? {
        await NetworkManager.shared.performRequest(
            responseType: VehicleServiceResponse.self,
            endpoint: .vehicleService(id: id)
        )
    }

    func save(vehicleService: VehicleService) async throws -> VehicleServiceResponse? {
        let request = vehicleService.toRequest()
        return await NetworkManager.shared.performRequest(
            responseType: VehicleServiceResponse.self,
            endpoint: .saveVehicleService(data: request, serverId: vehicleService.id)
        )
    }
}
