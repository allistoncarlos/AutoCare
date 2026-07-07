//
//  SyncService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 07/07/26.
//

import Factory
import Foundation
import SwiftData

@MainActor
final class SyncService {
    private let modelContext: ModelContext

    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
    @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func pushUnsyncedChanges() async {
        let vehicles = fetchUnsyncedChanges(modelType: Vehicle.self)
        for vehicle in vehicles {
            if await vehicleRepository.save(id: vehicle.id, vehicle: vehicle) != nil {
                vehicle.synced = true
            }
        }

        let mileages = fetchUnsyncedChanges(modelType: VehicleMileage.self)
        for mileage in mileages {
            if let id = mileage.id,
               await vehicleMileageRepository.save(id: id, vehicleMileage: mileage) != nil {
                mileage.synced = true
            }
        }

        let services = fetchUnsyncedChanges(modelType: VehicleService.self)
        for service in services {
            if await vehicleServiceRepository.save(id: service.id, vehicleService: service) != nil {
                service.synced = true
            }
        }

        try? modelContext.save()
    }

    func importRemoteData(
        vehicleTypes: [VehicleType],
        vehicles: [Vehicle],
        mileages: [VehicleMileage],
        services: [VehicleService]
    ) throws {
        try replaceAll(vehicleTypes)
        try replaceAll(vehicles)
        try replaceAll(mileages)
        try replaceAll(services)
    }

    private func fetchUnsyncedChanges<T>(modelType: T.Type) -> [T] where T: Syncable, T: PersistentModel {
        do {
            let descriptor = FetchDescriptor<T>(predicate: #Predicate { entity in
                entity.synced == false
            })
            return try modelContext.fetch(descriptor)
        } catch {
            print("Não foi possível retornar itens não sincronizados: \(error)")
            return []
        }
    }

    private func replaceAll<T: Syncable>(_ data: [T]) throws where T: PersistentModel {
        try modelContext.delete(model: T.self)

        data.forEach { item in
            item.synced = true
            modelContext.insert(item)
        }

        try modelContext.save()
    }
}
