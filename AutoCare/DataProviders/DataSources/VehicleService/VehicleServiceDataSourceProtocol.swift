//
//  VehicleServiceDataSourceProtocol.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation
import SwiftData

protocol VehicleServiceDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]?
    func fetchData(vehicleId: String,id: String) async -> VehicleService?
    func save(id: String?, vehicleService: VehicleService) async -> VehicleService?
}

class VehicleServiceDataSource: VehicleServiceDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: [VehicleServiceResponse].self,
                endpoint: .vehicleServices(vehicleId: vehicleId)
            ) {
                return apiResult
                    .compactMap { $0.toVehicleService() }
                    .sorted(by: {
                        $0.date.compare($1.date) == .orderedDescending
                    })
        }

        return nil
    }

    func fetchData(vehicleId: String,id: String) async -> VehicleService? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: VehicleServiceResponse.self,
                endpoint: .vehicleService(vehicleId: vehicleId, id: id)
            ) {
            return apiResult.toVehicleService()
        }

        return nil
    }

    func save(id: String?, vehicleService: VehicleService) async -> VehicleService? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: VehicleServiceResponse.self,
                endpoint: .saveVehicleService(id: id, data: vehicleService.toRequest())
            ) {
            return apiResult.toVehicleService()
        }

        return nil
    }
}
