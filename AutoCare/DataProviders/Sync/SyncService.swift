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
    private let changesDataSource: ChangesDataSourceProtocol

    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
    @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

    init(
        modelContext: ModelContext,
        changesDataSource: ChangesDataSourceProtocol = ChangesDataSource()
    ) {
        self.modelContext = modelContext
        self.changesDataSource = changesDataSource
    }

    func sync() async {
        await pushUnsyncedChanges()
        await pullRemoteChanges()
    }

    func pushUnsyncedChanges() async {
        let vehicles = fetchUnsyncedChanges(modelType: Vehicle.self)
        for vehicle in vehicles where vehicle.deleted == false {
            if await vehicleRepository.save(id: vehicle.id, vehicle: vehicle) != nil {
                vehicle.synced = true
            }
        }

        let mileages = fetchUnsyncedChanges(modelType: VehicleMileage.self)
        for mileage in mileages where mileage.deleted == false {
            if await vehicleMileageRepository.save(id: mileage.id, vehicleMileage: mileage) != nil {
                mileage.synced = true
            }
        }

        let services = fetchUnsyncedChanges(modelType: VehicleService.self)
        for service in services where service.deleted == false {
            if await vehicleServiceRepository.save(id: service.id, vehicleService: service) != nil {
                service.synced = true
            }
        }

        try? modelContext.save()
    }

    func pullRemoteChanges() async {
        guard let response = await changesDataSource.fetchChanges(since: SyncTimestampStore.lastSync) else {
            return
        }

        applyVehicleTypes(response.changes.vehicleTypes ?? [])
        applyVehicles(response.changes.vehicles ?? [])
        applyMileages(response.changes.vehicleMileages ?? [])
        applyServices(response.changes.vehicleServices ?? [])

        if let serverTime = ISO8601DateFormatter().date(from: response.serverTime) {
            SyncTimestampStore.lastSync = serverTime
        }

        try? modelContext.save()
    }

    private func applyVehicleTypes(_ changes: [SyncChangeResponse]) {
        for change in changes {
            guard let id = change.id ?? change.clientId else { continue }

            if change.deleted == true {
                if let existing = try? fetchVehicleType(id: id) {
                    modelContext.delete(existing)
                }
                continue
            }

            let entity = (try? fetchVehicleType(id: id)) ?? VehicleType(
                id: id,
                name: change.name ?? id,
                emoji: change.emoji ?? "🚗",
                clientId: change.clientId ?? id
            )

            if let existing = try? fetchVehicleType(id: id), existing !== entity {
                modelContext.delete(existing)
            }

            entity.name = change.name ?? entity.name
            entity.emoji = change.emoji ?? entity.emoji
            entity.clientId = change.clientId ?? entity.clientId
            entity.updatedAt = parseDate(change.updatedAt)
            entity.deleted = change.deleted ?? false
            entity.deletedAt = parseDate(change.deletedAt)
            entity.synced = true

            if (try? fetchVehicleType(id: id)) == nil {
                modelContext.insert(entity)
            }
        }
    }

    private func applyVehicles(_ changes: [SyncChangeResponse]) {
        for change in changes {
            if change.deleted == true {
                if let existing = findVehicle(remoteId: change.id, clientId: change.clientId) {
                    modelContext.delete(existing)
                }
                continue
            }

            guard
                let name = change.name,
                let brand = change.brand,
                let model = change.model,
                let year = change.year,
                let licensePlate = change.licensePlate,
                let vehicleTypeId = change.vehicleTypeId
            else { continue }

            let existing = findVehicle(remoteId: change.id, clientId: change.clientId)
            let vehicle = existing ?? Vehicle(
                id: change.id,
                name: name,
                brand: brand,
                model: model,
                year: year,
                licensePlate: licensePlate,
                odometer: change.odometer ?? 0,
                isDefault: change.isDefault ?? false,
                vehicleTypeId: vehicleTypeId,
                clientId: change.clientId
            )

            vehicle.id = change.id ?? vehicle.id
            vehicle.name = name
            vehicle.brand = brand
            vehicle.model = model
            vehicle.year = year
            vehicle.licensePlate = licensePlate
            vehicle.odometer = change.odometer ?? vehicle.odometer
            vehicle.isDefault = change.isDefault ?? vehicle.isDefault
            vehicle.vehicleTypeId = vehicleTypeId
            vehicle.clientId = change.clientId ?? vehicle.clientId
            vehicle.updatedAt = parseDate(change.updatedAt)
            vehicle.deleted = change.deleted ?? false
            vehicle.deletedAt = parseDate(change.deletedAt)
            vehicle.synced = true

            if existing == nil {
                modelContext.insert(vehicle)
            }
        }
    }

    private func applyMileages(_ changes: [SyncChangeResponse]) {
        for change in changes {
            if change.deleted == true {
                if let existing = findMileage(remoteId: change.id, clientId: change.clientId) {
                    modelContext.delete(existing)
                }
                continue
            }

            guard
                let date = change.date,
                let vehicleId = change.vehicleId
            else { continue }

            let existing = findMileage(remoteId: change.id, clientId: change.clientId)
            let mileage = existing ?? VehicleMileage(
                id: change.id,
                date: date,
                totalCost: change.totalCost ?? 0,
                odometer: change.odometer ?? 0,
                odometerDifference: change.odometerDifference ?? 0,
                liters: change.liters ?? 0,
                fuelCost: change.fuelCost ?? 0,
                calculatedMileage: change.calculatedMileage ?? 0,
                complete: change.complete ?? true,
                vehicleId: vehicleId,
                clientId: change.clientId
            )

            mileage.id = change.id ?? mileage.id
            mileage.date = date
            mileage.totalCost = change.totalCost ?? mileage.totalCost
            mileage.odometer = change.odometer ?? mileage.odometer
            mileage.odometerDifference = change.odometerDifference ?? mileage.odometerDifference
            mileage.liters = change.liters ?? mileage.liters
            mileage.fuelCost = change.fuelCost ?? mileage.fuelCost
            mileage.calculatedMileage = change.calculatedMileage ?? mileage.calculatedMileage
            mileage.complete = change.complete ?? mileage.complete
            mileage.vehicleId = vehicleId
            mileage.clientId = change.clientId ?? mileage.clientId
            mileage.updatedAt = parseDate(change.updatedAt)
            mileage.deleted = change.deleted ?? false
            mileage.deletedAt = parseDate(change.deletedAt)
            mileage.synced = true

            if existing == nil {
                modelContext.insert(mileage)
            }
        }
    }

    private func applyServices(_ changes: [SyncChangeResponse]) {
        for change in changes {
            if change.deleted == true {
                if let existing = findService(remoteId: change.id, clientId: change.clientId) {
                    modelContext.delete(existing)
                }
                continue
            }

            guard
                let date = change.date,
                let vehicleId = change.vehicleId,
                let type = change.type,
                let subtype = change.subtype,
                let remoteId = change.id
            else { continue }

            let existing = findService(remoteId: change.id, clientId: change.clientId)
            let service = existing ?? VehicleService(
                id: remoteId,
                date: date,
                odometer: change.odometer ?? 0,
                type: VehicleServiceType(rawValue: type) ?? .wheelsAndTyres,
                subtype: VehicleServiceSubtype(rawValue: subtype) ?? .calibrate,
                totalCost: change.totalCost ?? 0,
                comment: change.comment ?? "",
                vehicle_id: vehicleId,
                clientId: change.clientId
            )

            service.id = remoteId
            service.date = date
            service.odometer = change.odometer ?? service.odometer
            service.type = VehicleServiceType(rawValue: type) ?? service.type
            service.subtype = VehicleServiceSubtype(rawValue: subtype) ?? service.subtype
            service.totalCost = change.totalCost ?? service.totalCost
            service.comment = change.comment ?? service.comment
            service.vehicle_id = vehicleId
            service.clientId = change.clientId ?? service.clientId
            service.updatedAt = parseDate(change.updatedAt)
            service.deleted = change.deleted ?? false
            service.deletedAt = parseDate(change.deletedAt)
            service.synced = true

            if existing == nil {
                modelContext.insert(service)
            }
        }
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

    private func fetchVehicleType(id: String) throws -> VehicleType? {
        try localFetchOne { $0.id == id }
    }

    private func findVehicle(remoteId: String?, clientId: String?) -> Vehicle? {
        if let remoteId, let vehicle: Vehicle = try? localFetchOne({ $0.id == remoteId }) {
            return vehicle
        }
        if let clientId, let vehicle: Vehicle = try? localFetchOne({ $0.clientId == clientId }) {
            return vehicle
        }
        return nil
    }

    private func findMileage(remoteId: String?, clientId: String?) -> VehicleMileage? {
        if let remoteId, let mileage: VehicleMileage = try? localFetchOne({ $0.id == remoteId }) {
            return mileage
        }
        if let clientId, let mileage: VehicleMileage = try? localFetchOne({ $0.clientId == clientId }) {
            return mileage
        }
        return nil
    }

    private func findService(remoteId: String?, clientId: String?) -> VehicleService? {
        if let remoteId, let service: VehicleService = try? localFetchOne({ $0.id == remoteId }) {
            return service
        }
        if let clientId, let service: VehicleService = try? localFetchOne({ $0.clientId == clientId }) {
            return service
        }
        return nil
    }

    private func localFetchOne<T: PersistentModel>(_ predicate: (T) -> Bool) throws -> T? {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor).first(where: predicate)
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return ISO8601DateFormatter().date(from: value)
    }
}
