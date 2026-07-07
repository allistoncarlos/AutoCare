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
    func save<T: PersistentModel>(item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func importData<T: PersistentModel>(_ data: [T]) throws {
        try modelContext.delete(model: T.self)
        data.forEach { modelContext.insert($0) }
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

    func fetch<T: PersistentModel>(where predicate: Predicate<T>) throws -> T? {
        try fetch(where: predicate).first
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
        do {
            container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            )
            context = ModelContext(container)
            previewModelContainer = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            actor = SwiftDataActor(modelContainer: container)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetch<T: PersistentModel>() async throws -> [T] {
        try await fetch(sortBy: [])
    }

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await actor.fetch(sortBy: sortBy)
    }

    func fetch<T: PersistentModel>(where predicate: Predicate<T>) async throws -> [T] {
        try await actor.fetch(where: predicate)
    }

    func fetch<T: PersistentModel>(where predicate: Predicate<T>) async throws -> T? {
        try await actor.fetch(where: predicate)
    }

    func save<T: PersistentModel>(item: T) async throws {
        try await actor.save(item: item)
    }

    func importData<T: PersistentModel>(_ data: [T]) async throws {
        try await actor.importData(data)
    }
}
