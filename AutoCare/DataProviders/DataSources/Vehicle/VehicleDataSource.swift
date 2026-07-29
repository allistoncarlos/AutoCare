//
//  VehicleDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation

protocol VehicleDataSourceProtocol {
    func fetchData() async -> [VehicleResponse]?
    func fetchData(id: String) async -> VehicleResponse?
    func save(vehicle: Vehicle) async throws -> VehicleResponse?
}

class VehicleDataSource: VehicleDataSourceProtocol {
    func fetchData() async -> [VehicleResponse]? {
        await NetworkManager.shared.performRequest(
            responseType: [VehicleResponse].self,
            endpoint: .vehicles
        )
    }

    func fetchData(id: String) async -> VehicleResponse? {
        await NetworkManager.shared.performRequest(
            responseType: VehicleResponse.self,
            endpoint: .vehicle(id: id)
        )
    }

    func save(vehicle: Vehicle) async throws -> VehicleResponse? {
        let request = vehicle.toRequest()
        return await NetworkManager.shared.performRequest(
            responseType: VehicleResponse.self,
            endpoint: .saveVehicle(data: request, serverId: vehicle.id)
        )
    }
}
