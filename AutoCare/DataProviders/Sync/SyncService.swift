//
//  SyncService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 07/07/26.
//

import Factory
import Foundation

@MainActor
final class SyncService {
    @Injected(\.swiftDataManager) private var swiftDataManager
    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
    @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

    private let changesDataSource: ChangesDataSourceProtocol

    init(changesDataSource: ChangesDataSourceProtocol = ChangesDataSource()) {
        self.changesDataSource = changesDataSource
    }

    func sync() async {
        await pushUnsyncedChanges()
        await pullRemoteChanges()
    }

    func pushUnsyncedChanges() async {
        do {
            let vehicles = try await swiftDataManager.fetchUnsynced(Vehicle.self)
            for vehicle in vehicles where vehicle.deleted == false {
                if await vehicleRepository.save(id: vehicle.id, vehicle: vehicle) != nil {
                    try await swiftDataManager.markSynced(vehicle)
                }
            }

            let mileages = try await swiftDataManager.fetchUnsynced(VehicleMileage.self)
            for mileage in mileages where mileage.deleted == false {
                if await vehicleMileageRepository.save(id: mileage.id, vehicleMileage: mileage) != nil {
                    try await swiftDataManager.markSynced(mileage)
                }
            }

            let services = try await swiftDataManager.fetchUnsynced(VehicleService.self)
            for service in services where service.deleted == false {
                if await vehicleServiceRepository.save(id: service.id, vehicleService: service) != nil {
                    try await swiftDataManager.markSynced(service)
                }
            }
        } catch {
            print("Não foi possível enviar alterações locais: \(error)")
        }
    }

    func pullRemoteChanges() async {
        guard let response = await changesDataSource.fetchChanges(since: SyncTimestampStore.lastSync) else {
            return
        }

        do {
            try await swiftDataManager.applyRemoteChanges(response.changes)

            if let serverTime = ISO8601DateFormatter().date(from: response.serverTime) {
                SyncTimestampStore.lastSync = serverTime
            }
        } catch {
            print("Não foi possível aplicar alterações remotas: \(error)")
        }
    }
}
