//
//  VehicleDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation

protocol VehicleDataSourceProtocol {
    func fetchData() async -> [VehicleData]?
    func fetchData(id: String) async -> VehicleData?
}

// MARK: - VehicleDataSource

class VehicleDataSource: VehicleDataSourceProtocol {
    func fetchData() async -> [VehicleData]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: [VehicleResponse].self,
                endpoint: .vehicles
            ) {
                return apiResult
                    .compactMap { $0.toVehicle() }
                    .sorted(by: { $1.name.uppercased() > $0.name.uppercased() })
        }

        return nil
    }

    func fetchData(id: String) async -> VehicleData? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: VehicleResponse.self,
                endpoint: .vehicle(id: id)
            ) {
            return apiResult.toVehicle()
        }

        return nil
    }
}
