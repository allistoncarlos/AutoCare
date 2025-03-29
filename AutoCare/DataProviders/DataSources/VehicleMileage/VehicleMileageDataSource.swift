//
//  VehicleMileageDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Foundation

protocol VehicleMileageDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]?
    func fetchData(vehicleId: String,id: String) async -> VehicleMileage?
    func save(id: String?, vehicleMileage: VehicleMileage) async -> VehicleMileage?
}

class VehicleMileageDataSource: VehicleMileageDataSourceProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: [VehicleMileageResponse].self,
                endpoint: .vehicleMileages(vehicleId: vehicleId)
            ) {
                return apiResult
                    .compactMap { $0.toVehicleMileage() }
                    .sorted(by: {
                        $0.date.compare($1.date) == .orderedDescending
                    })
        }

        return nil
    }

    func fetchData(vehicleId: String,id: String) async -> VehicleMileage? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: VehicleMileageResponse.self,
                endpoint: .vehicleMileage(vehicleId: vehicleId, id: id)
            ) {
            return apiResult.toVehicleMileage()
        }

        return nil
    }

    func save(id: String?, vehicleMileage: VehicleMileage) async -> VehicleMileage? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: VehicleMileageResponse.self,
                endpoint: .saveVehicleMileage(id: id, data: vehicleMileage.toRequest())
            ) {
            return apiResult.toVehicleMileage()
        }

        return nil
    }
}
