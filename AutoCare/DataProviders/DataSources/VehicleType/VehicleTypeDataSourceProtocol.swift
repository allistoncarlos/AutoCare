//
//  VehicleTypeDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//


protocol VehicleTypeDataSourceProtocol {
    func fetchData() async -> [VehicleTypeData]?
}

class VehicleTypeDataSource: VehicleTypeDataSourceProtocol {
    func fetchData() async -> [VehicleTypeData]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: [VehicleTypeResponse].self,
                endpoint: .vehicleType
            ) {
                return apiResult
                    .compactMap { $0.toVehicleType() }
                    .sorted(by: { $1.name.uppercased() > $0.name.uppercased() })
        }

        return nil
    }
}
