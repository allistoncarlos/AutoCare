//
//  VehicleRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Factory
import Foundation

protocol VehicleRepositoryProtocol {
    func fetchData() async -> [Vehicle]?
    func fetchData(id: String) async -> Vehicle?
    @discardableResult func save(vehicle: Vehicle) async -> Vehicle?
}

struct VehicleRepository: VehicleRepositoryProtocol {
    func fetchData() async -> [Vehicle]? {
        do {
            return try await SwiftDataManager.shared.fetch(
                sortBy: [SortDescriptor(\Vehicle.name, order: .forward)]
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func fetchData(id: String) async -> Vehicle? {
        do {
            return try await SwiftDataManager.shared.fetchOne(
                where: #Predicate<Vehicle> { $0.clientId == id }
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func save(vehicle: Vehicle) async -> Vehicle? {
        do {
            let result: Vehicle = try await SwiftDataManager.shared.save(id: vehicle.id, item: vehicle)

            BackgroundWorker.shared.run {
                if let savedVehicle = try await dataSource.save(vehicle: vehicle) {
                    let persistentEntity = Vehicle(from: savedVehicle)
                    try await SwiftDataManager.shared.updateFromBackend(
                        clientId: persistentEntity.clientId,
                        item: persistentEntity
                    )
                }
            }

            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    @Injected(\.vehicleDataSource) var dataSource: VehicleDataSourceProtocol
}
