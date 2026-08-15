//
//  VehicleServiceRepositoryProtocol.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Factory
import Foundation

protocol VehicleServiceRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]?
    func fetchData(vehicleId: String, id: String) async -> VehicleService?
    @discardableResult func save(vehicleService: VehicleService) async -> VehicleService?
    @discardableResult func delete(vehicleService: VehicleService) async -> Bool
}

struct VehicleServiceRepository: VehicleServiceRepositoryProtocol {
    func fetchData(vehicleId: String) async -> [VehicleService]? {
        do {
            return try await SwiftDataManager.shared.fetch(
                where: #Predicate<VehicleService> { service in
                    service.vehicle_id == vehicleId && !service.deleted
                },
                sortBy: [SortDescriptor(\VehicleService.date, order: .reverse)]
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func fetchData(vehicleId: String, id: String) async -> VehicleService? {
        do {
            return try await SwiftDataManager.shared.fetchOne(
                where: #Predicate<VehicleService> { $0.clientId == id }
            )
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func save(vehicleService: VehicleService) async -> VehicleService? {
        do {
            let result: VehicleService = try await SwiftDataManager.shared.save(
                id: vehicleService.id,
                item: vehicleService
            )

            BackgroundWorker.shared.run {
                if let savedService = try await dataSource.save(vehicleService: vehicleService) {
                    let persistentEntity = VehicleService(from: savedService)
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

    func delete(vehicleService: VehicleService) async -> Bool {
        do {
            let hasRemoteId = !(vehicleService.id ?? "").isEmpty
            let clientId = vehicleService.clientId

            vehicleService.deleted = true
            vehicleService.deletedAt = .now
            vehicleService.synced = !hasRemoteId

            _ = try await SwiftDataManager.shared.save(
                id: vehicleService.id ?? clientId,
                item: vehicleService
            )

            guard hasRemoteId else { return true }

            BackgroundWorker.shared.run {
                if let deletedService = try await dataSource.delete(clientId: clientId) {
                    let persistentEntity = VehicleService(from: deletedService)
                    try await SwiftDataManager.shared.updateFromBackend(
                        clientId: persistentEntity.clientId,
                        item: persistentEntity
                    )
                }
            }

            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    @Injected(\.vehicleServiceDataSource) var dataSource: VehicleServiceDataSourceProtocol
}
