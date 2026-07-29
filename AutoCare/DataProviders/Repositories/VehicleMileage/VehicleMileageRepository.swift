//
//  VehicleMileageRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 29/03/25.
//

import Factory
import Foundation

protocol VehicleMileageRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]?
    func fetchData(vehicleId: String, id: String) async -> VehicleMileage?
    @discardableResult func save(vehicleMileage: VehicleMileage) async -> VehicleMileage?
}

struct VehicleMileageRepository: VehicleMileageRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleMileage]? {
        do {
            return try await SwiftDataManager.shared.fetch(
                where: #Predicate<VehicleMileage> { mileage in
                    mileage.vehicleId == vehicleId && !mileage.deleted
                },
                sortBy: [SortDescriptor(\VehicleMileage.date, order: .reverse)]
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func fetchData(vehicleId: String, id: String) async -> VehicleMileage? {
        do {
            return try await SwiftDataManager.shared.fetchOne(
                where: #Predicate<VehicleMileage> { $0.clientId == id }
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func save(vehicleMileage: VehicleMileage) async -> VehicleMileage? {
        do {
            let result: VehicleMileage = try await SwiftDataManager.shared.save(
                id: vehicleMileage.id,
                item: vehicleMileage
            )

            BackgroundWorker.shared.run {
                if let savedMileage = try await dataSource.save(vehicleMileage: vehicleMileage) {
                    let persistentEntity = VehicleMileage(from: savedMileage)
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

    @Injected(\.vehicleMileageDataSource) var dataSource: VehicleMileageDataSourceProtocol
}
