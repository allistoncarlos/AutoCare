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
    func save<T: PersistentModel>(id: String? = nil, item: T) throws -> T {
        if let id, !id.isEmpty {
            try modelContext.save()
            return item
        }

        modelContext.insert(item)
        try modelContext.save()
        return item
    }

    func updateFromBackend<T: Syncable & PersistentModel>(clientId: String, item: T) async throws {
        let descriptor = FetchDescriptor<T>(
            predicate: #Predicate { $0.clientId == clientId }
        )

        if let local = try modelContext.fetch(descriptor).first {
            await MainActor.run {
                item.applyRemoteChanges(to: local)
                local.synced = true
            }
            try modelContext.save()
        }
    }

    func importData<T: Syncable>(_ data: [T]) async throws where T: PersistentModel {
        try modelContext.delete(model: T.self)

        for item in data {
            await MainActor.run {
                item.synced = true
            }
            _ = try save(id: nil, item: item)
        }
    }

    func mergeData<T: Syncable>(_ data: [T]) throws where T: PersistentModel {
        for item in data {
            item.synced = true

            let clientId = item.clientId
            let descriptor = FetchDescriptor<T>(
                predicate: #Predicate { $0.clientId == clientId }
            )

            if let local = try modelContext.fetch(descriptor).first {
                item.applyRemoteChanges(to: local)
            } else {
                modelContext.insert(item)
            }
        }

        try modelContext.save()
    }

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }

    func fetch<T: PersistentModel>(where predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: [])
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

    func delete<T: PersistentModel>(_ item: T) throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func backfillClientIds() throws {
        var didChange = false

        let vehicles: [Vehicle] = try fetch(sortBy: [])
        for vehicle in vehicles where vehicle.clientId.isEmpty {
            vehicle.ensureClientId(from: vehicle.id)
            vehicle.synced = false
            didChange = true
        }

        let mileages: [VehicleMileage] = try fetch(sortBy: [])
        for mileage in mileages where mileage.clientId.isEmpty {
            mileage.ensureClientId(from: mileage.id)
            mileage.synced = false
            didChange = true
        }

        let services: [VehicleService] = try fetch(sortBy: [])
        for service in services where service.clientId.isEmpty {
            service.ensureClientId(from: service.id)
            service.synced = false
            didChange = true
        }

        let types: [VehicleType] = try fetch(sortBy: [])
        for type in types where type.clientId.isEmpty {
            type.ensureClientId(from: type.id)
            type.synced = false
            didChange = true
        }

        if didChange {
            try modelContext.save()
        }
    }
}

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
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            print("SwiftData store failed to load: \(error.localizedDescription)")
            Self.removePersistentStoreFiles()
            do {
                container = try ModelContainer(for: schema, configurations: configuration)
            } catch {
                fatalError("SwiftData store could not be created after reset: \(error.localizedDescription)")
            }
        }

        context = ModelContext(container)
        previewModelContainer = try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        actor = SwiftDataActor(modelContainer: container)

        Task { try? await self.backfillClientIds() }
    }

    func fetch<T: PersistentModel>() async throws -> [T] {
        try await fetch(sortBy: [])
    }

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await actor.fetch(sortBy: sortBy)
    }

    func fetch<T: PersistentModel>(where predicate: Predicate<T>, sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await actor.fetch(where: predicate, sortBy: sortBy)
    }

    func fetchOne<T: PersistentModel>(where predicate: Predicate<T>) async throws -> T? {
        try await actor.fetchOne(where: predicate)
    }

    func fetchUnsyncedEntities() throws -> [any PersistentModel] {
        var unsyncedEntities: [any PersistentModel] = []

        let vehicles = try context.fetch(
            FetchDescriptor<Vehicle>(predicate: #Predicate { !$0.synced })
        )
        let mileages = try context.fetch(
            FetchDescriptor<VehicleMileage>(predicate: #Predicate { !$0.synced })
        )
        let services = try context.fetch(
            FetchDescriptor<VehicleService>(predicate: #Predicate { !$0.synced })
        )

        unsyncedEntities.append(contentsOf: vehicles)
        unsyncedEntities.append(contentsOf: mileages)
        unsyncedEntities.append(contentsOf: services)

        return unsyncedEntities
    }

    func save<T: PersistentModel>(id: String? = nil, item: T) async throws -> T {
        try await actor.save(id: id, item: item)
    }

    func updateFromBackend<T: Syncable>(clientId: String, item: T) async throws where T: PersistentModel {
        try await actor.updateFromBackend(clientId: clientId, item: item)
    }

    func importData<T: Syncable>(_ data: [T]) async throws where T: PersistentModel {
        try await actor.importData(data)
    }

    func mergeData<T: Syncable>(_ data: [T]) async throws where T: PersistentModel {
        try await actor.mergeData(data)
    }

    func delete<T: PersistentModel>(_ item: T) async throws {
        try await actor.delete(item)
    }

    func backfillClientIds() async throws {
        try await actor.backfillClientIds()
    }

    func applyChanges<T: Syncable>(_ incoming: [T]) throws where T: PersistentModel {
        for remote in incoming {
            let clientId = remote.clientId

            let descriptor = FetchDescriptor<T>(
                predicate: #Predicate { $0.clientId == clientId }
            )

            let local = try context.fetch(descriptor).first

            if remote.deleted {
                if let local {
                    context.delete(local)
                }
                continue
            }

            if let local {
                remote.applyRemoteChanges(to: local)
            } else {
                context.insert(remote)
            }
        }

        try context.save()
    }

    func applyRemoteChanges(_ changes: ChangesPayloadResponse) throws {
        try applyChanges(changes.vehicleTypes?.compactMap { VehicleType(from: $0) } ?? [])
        try applyChanges(changes.vehicles?.compactMap { Vehicle(from: $0) } ?? [])
        try applyChanges(changes.vehicleMileages?.compactMap { VehicleMileage(from: $0) } ?? [])
        try applyChanges(changes.vehicleServices?.compactMap { VehicleService(from: $0) } ?? [])
    }
}

private extension SwiftDataManager {
    static func applicationSupportURL() -> URL {
        let fileManager = FileManager.default
        let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupport ?? fileManager.temporaryDirectory
    }

    static func removePersistentStoreFiles(filename: String = "default.store") {
        let baseURL = applicationSupportURL().appendingPathComponent(filename)
        let sidecarSHM = baseURL.appendingPathExtension("shm")
        let sidecarWAL = baseURL.appendingPathExtension("wal")

        let fileManager = FileManager.default
        for url in [baseURL, sidecarSHM, sidecarWAL] where fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}

private extension ISO8601DateFormatter {
    static func parseSyncDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}

extension VehicleType {
    convenience init?(from change: SyncChangeResponse) {
        guard let id = change.id ?? change.clientId else { return nil }

        self.init(
            id: id,
            name: change.name ?? id,
            emoji: change.emoji ?? "🚗",
            clientId: SyncDefaults.resolveClientId(change.clientId, id: id),
            synced: true,
            createdAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            updatedAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            deleted: change.deleted ?? false,
            deletedAt: ISO8601DateFormatter.parseSyncDate(change.deletedAt)
        )
    }

    convenience init(from response: VehicleTypeResponse) {
        self.init(
            id: response.id,
            name: response.name,
            emoji: response.emoji,
            clientId: SyncDefaults.resolveClientId(nil, id: response.id),
            synced: true
        )
    }

    func applyRemoteChanges(to local: VehicleType) {
        local.id = id ?? local.id
        local.clientId = clientId
        local.deleted = deleted
        local.deletedAt = deletedAt
        local.updatedAt = updatedAt
        local.synced = true
        local.name = name
        local.emoji = emoji
    }
}

extension Vehicle {
    convenience init?(from change: SyncChangeResponse) {
        guard
            let name = change.name,
            let brand = change.brand,
            let model = change.model,
            let year = change.year,
            let licensePlate = change.licensePlate,
            let vehicleTypeId = change.vehicleTypeId
        else { return nil }

        self.init(
            id: change.id,
            name: name,
            brand: brand,
            model: model,
            year: year,
            licensePlate: licensePlate,
            odometer: change.odometer ?? 0,
            isDefault: change.isDefault ?? false,
            vehicleTypeId: vehicleTypeId,
            clientId: SyncDefaults.resolveClientId(change.clientId, id: change.id),
            synced: true,
            createdAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            updatedAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            deleted: change.deleted ?? false,
            deletedAt: ISO8601DateFormatter.parseSyncDate(change.deletedAt)
        )
    }

    convenience init(from response: VehicleResponse) {
        self.init(
            id: response.id,
            name: response.name,
            brand: response.brand,
            model: response.model,
            year: response.year,
            licensePlate: response.licensePlate,
            odometer: response.odometer,
            isDefault: response.isDefault,
            vehicleTypeId: response.vehicleType.id,
            clientId: SyncDefaults.resolveClientId(response.clientId, id: response.id),
            synced: false,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            deleted: response.deleted ?? false,
            deletedAt: response.deletedAt
        )
    }

    func applyRemoteChanges(to local: Vehicle) {
        local.id = id
        local.clientId = clientId
        local.deleted = deleted
        local.deletedAt = deletedAt
        local.updatedAt = updatedAt
        local.synced = true
        local.name = name
        local.brand = brand
        local.model = model
        local.year = year
        local.licensePlate = licensePlate
        local.odometer = odometer
        local.isDefault = isDefault
        local.vehicleTypeId = vehicleTypeId
    }
}

extension VehicleMileage {
    convenience init?(from change: SyncChangeResponse) {
        guard let date = change.date, let vehicleId = change.vehicleId else { return nil }

        self.init(
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
            clientId: SyncDefaults.resolveClientId(change.clientId, id: change.id),
            synced: true,
            createdAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            updatedAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            deleted: change.deleted ?? false,
            deletedAt: ISO8601DateFormatter.parseSyncDate(change.deletedAt)
        )
    }

    convenience init(from response: VehicleMileageResponse) {
        self.init(
            id: response.id,
            date: response.date,
            totalCost: response.totalCost,
            odometer: response.odometer,
            odometerDifference: response.odometerDifference,
            liters: response.liters,
            fuelCost: response.fuelCost,
            calculatedMileage: response.calculatedMileage,
            complete: response.complete,
            vehicleId: response.vehicleId,
            clientId: SyncDefaults.resolveClientId(response.clientId, id: response.id),
            synced: false,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            deleted: response.deleted ?? false,
            deletedAt: response.deletedAt
        )
    }

    func applyRemoteChanges(to local: VehicleMileage) {
        local.id = id
        local.clientId = clientId
        local.deleted = deleted
        local.deletedAt = deletedAt
        local.updatedAt = updatedAt
        local.synced = true
        local.date = date
        local.totalCost = totalCost
        local.odometer = odometer
        local.odometerDifference = odometerDifference
        local.liters = liters
        local.fuelCost = fuelCost
        local.calculatedMileage = calculatedMileage
        local.complete = complete
        local.vehicleId = vehicleId
    }
}

extension VehicleService {
    convenience init?(from change: SyncChangeResponse) {
        guard
            let date = change.date,
            let vehicleId = change.vehicleId,
            let type = change.type,
            let subtype = change.subtype
        else { return nil }

        self.init(
            id: change.id,
            date: date,
            odometer: change.odometer ?? 0,
            type: VehicleServiceType(rawValue: type) ?? .wheelsAndTyres,
            subtype: VehicleServiceSubtype(rawValue: subtype) ?? .calibrate,
            totalCost: change.totalCost ?? 0,
            comment: change.comment ?? "",
            vehicle_id: vehicleId,
            clientId: SyncDefaults.resolveClientId(change.clientId, id: change.id),
            synced: true,
            createdAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            updatedAt: ISO8601DateFormatter.parseSyncDate(change.updatedAt),
            deleted: change.deleted ?? false,
            deletedAt: ISO8601DateFormatter.parseSyncDate(change.deletedAt)
        )
    }

    convenience init(from response: VehicleServiceResponse) {
        self.init(
            id: response.id,
            date: response.date,
            odometer: response.odometer,
            type: VehicleServiceType(rawValue: response.type) ?? .wheelsAndTyres,
            subtype: VehicleServiceSubtype(rawValue: response.subtype) ?? .calibrate,
            totalCost: response.totalCost,
            comment: response.comment,
            vehicle_id: response.vehicleId,
            clientId: SyncDefaults.resolveClientId(response.clientId, id: response.id),
            synced: false,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            deleted: response.deleted ?? false,
            deletedAt: response.deletedAt
        )
    }

    func applyRemoteChanges(to local: VehicleService) {
        local.id = id
        local.clientId = clientId
        local.deleted = deleted
        local.deletedAt = deletedAt
        local.updatedAt = updatedAt
        local.synced = true
        local.date = date
        local.odometer = odometer
        local.type = type
        local.subtype = subtype
        local.totalCost = totalCost
        local.comment = comment
        local.vehicle_id = vehicle_id
    }
}
