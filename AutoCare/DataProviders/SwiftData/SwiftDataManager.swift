//
//  SwiftDataManager.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 01/04/25.
//

import Foundation
import SwiftData

@ModelActor
actor SwiftDataActor {
    func insert<T: PersistentModel>(_ item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func delete<T: PersistentModel>(_ item: T) throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        try modelContext.delete(model: type)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func importData<T: Syncable>(_ data: [T]) throws where T: PersistentModel {
        try modelContext.delete(model: T.self)

        for item in data {
            item.synced = true
            modelContext.insert(item)
        }

        try modelContext.save()
    }

    func replaceAll<T: Syncable>(_ data: [T], where predicate: Predicate<T>) throws where T: PersistentModel {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let existing = try modelContext.fetch(descriptor)
        existing.forEach { modelContext.delete($0) }

        for item in data {
            item.synced = true
            modelContext.insert(item)
        }

        try modelContext.save()
    }

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }

    func fetch<T: PersistentModel>(
        where predicate: Predicate<T>,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }

    func fetchOne<T: PersistentModel>(where predicate: Predicate<T>) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func fetchUnsynced<T: Syncable>(_ type: T.Type) throws -> [T] where T: PersistentModel {
        let descriptor = FetchDescriptor<T>(predicate: #Predicate { entity in
            entity.synced == false
        })
        return try modelContext.fetch(descriptor)
    }

    func markSynced<T: Syncable>(_ item: T) throws where T: PersistentModel {
        item.synced = true
        try modelContext.save()
    }

    func applyRemoteChanges(_ changes: ChangesPayloadResponse) throws {
        applyVehicleTypes(changes.vehicleTypes ?? [])
        applyVehicles(changes.vehicles ?? [])
        applyMileages(changes.vehicleMileages ?? [])
        applyServices(changes.vehicleServices ?? [])
        try modelContext.save()
    }

    private func applyVehicleTypes(_ changes: [SyncChangeResponse]) {
        for change in changes {
            guard let id = change.id ?? change.clientId else { continue }

            if change.deleted == true {
                if let existing = try? fetchOne(where: #Predicate<VehicleType> { $0.id == id }) {
                    modelContext.delete(existing)
                }
                continue
            }

            let entity = (try? fetchOne(where: #Predicate<VehicleType> { $0.id == id })) ?? VehicleType(
                id: id,
                name: change.name ?? id,
                emoji: change.emoji ?? "🚗",
                clientId: change.clientId ?? id
            )

            entity.name = change.name ?? entity.name
            entity.emoji = change.emoji ?? entity.emoji
            entity.clientId = change.clientId ?? entity.clientId
            entity.updatedAt = parseDate(change.updatedAt)
            entity.deleted = change.deleted ?? false
            entity.deletedAt = parseDate(change.deletedAt)
            entity.synced = true

            if (try? fetchOne(where: #Predicate<VehicleType> { $0.id == id })) == nil {
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

            guard let date = change.date, let vehicleId = change.vehicleId else { continue }

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

    private func findVehicle(remoteId: String?, clientId: String?) -> Vehicle? {
        if let remoteId, let vehicle = try? fetchOne(where: #Predicate<Vehicle> { $0.id == remoteId }) {
            return vehicle
        }
        if let clientId, let vehicle = try? fetchOne(where: #Predicate<Vehicle> { $0.clientId == clientId }) {
            return vehicle
        }
        return nil
    }

    private func findMileage(remoteId: String?, clientId: String?) -> VehicleMileage? {
        if let remoteId, let mileage = try? fetchOne(where: #Predicate<VehicleMileage> { $0.id == remoteId }) {
            return mileage
        }
        if let clientId, let mileage = try? fetchOne(where: #Predicate<VehicleMileage> { $0.clientId == clientId }) {
            return mileage
        }
        return nil
    }

    private func findService(remoteId: String?, clientId: String?) -> VehicleService? {
        if let remoteId, let service = try? fetchOne(where: #Predicate<VehicleService> { $0.id == remoteId }) {
            return service
        }
        if let clientId, let service = try? fetchOne(where: #Predicate<VehicleService> { $0.clientId == clientId }) {
            return service
        }
        return nil
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return ISO8601DateFormatter().date(from: value)
    }
}

@MainActor
final class SwiftDataManager {
    let schema = Schema([
        VehicleType.self,
        Vehicle.self,
        VehicleMileage.self,
        VehicleService.self
    ])

    let container: ModelContainer
    let context: ModelContext
    let previewModelContainer: ModelContainer

    private let actor: SwiftDataActor

    static let shared = SwiftDataManager()

    private init() {
        do {
            container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            )
            context = ModelContext(container)
            previewModelContainer = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            actor = SwiftDataActor(modelContainer: container)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await actor.fetch(sortBy: sortBy)
    }

    func fetch<T: PersistentModel>(
        where predicate: Predicate<T>,
        sortBy: [SortDescriptor<T>] = []
    ) async throws -> [T] {
        try await actor.fetch(where: predicate, sortBy: sortBy)
    }

    func fetchOne<T: PersistentModel>(where predicate: Predicate<T>) async throws -> T? {
        try await actor.fetchOne(where: predicate)
    }

    func insert<T: PersistentModel>(_ item: T) async throws {
        try await actor.insert(item)
    }

    func delete<T: PersistentModel>(_ item: T) async throws {
        try await actor.delete(item)
    }

    func deleteAll<T: PersistentModel>(_ type: T.Type) async throws {
        try await actor.deleteAll(type)
    }

    func save() async throws {
        try await actor.save()
    }

    func importData<T: Syncable>(_ data: [T]) async throws where T: PersistentModel {
        try await actor.importData(data)
    }

    func replaceAll<T: Syncable>(_ data: [T], where predicate: Predicate<T>) async throws where T: PersistentModel {
        try await actor.replaceAll(data, where: predicate)
    }

    func fetchUnsynced<T: Syncable>(_ type: T.Type) async throws -> [T] where T: PersistentModel {
        try await actor.fetchUnsynced(type)
    }

    func markSynced<T: Syncable>(_ item: T) async throws where T: PersistentModel {
        try await actor.markSynced(item)
    }

    func applyRemoteChanges(_ changes: ChangesPayloadResponse) async throws {
        try await actor.applyRemoteChanges(changes)
    }
}
