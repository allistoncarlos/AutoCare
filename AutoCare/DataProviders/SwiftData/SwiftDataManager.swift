//
//  SwiftDataManager.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 01/04/25.
//

import SwiftData
import Foundation

@ModelActor
actor SwiftDataActor {
    func save<T: PersistentModel>(id: String? = nil, item: T) throws {
        if let id {
            try update(id: id, item: item)
        } else {
            try insert(item: item)
        }
        
        try modelContext.save()
    }
    
    func importData<T: PersistentModel>(_ data: [T]) throws {
        try modelContext.delete(model: T.self)
        
        try data.forEach { item in
            try save(item: item)
        }
    }
    
    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        
        let result = try modelContext.fetch(descriptor)
        
        return result
    }
    
    func fetch<T: PersistentModel>(where predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: [])
        
        let result = try modelContext.fetch(descriptor)
        
        return result
    }
    
    func fetch<T: PersistentModel>(where predicate: Predicate<T>) throws -> T? {
        return try fetch(where: predicate).first
    }
    
    private func update<T: PersistentModel>(id: String, item: T) throws {
//        let descriptor = createUpdateDescriptor(for: id)
//
//        let result = try SwiftDataManager.shared.context.fetch(descriptor)
//
//        if result.count == 1, let itemsResult = result.first {
//            vehicleMileageResult.synced = false
//            try SwiftDataManager.shared.context.save()
//        }
    }
    
    private func insert<T: PersistentModel>(item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
}

final class SwiftDataManager {
    let schema = Schema([
        VehicleType.self,
        Vehicle.self,
        VehicleMileage.self
    ])
    
    let container: ModelContainer
    let context: ModelContext
    let previewModelContainer: ModelContainer
    
    private let actor: SwiftDataActor
    
    static let shared = SwiftDataManager()
    
    var hasFetchedInitialData: Bool {
        get async {
            do {
                let result: [VehicleType] = try await actor.fetch(sortBy: [])
                return !result.isEmpty
            } catch { return false }
        }
    }
    
    private init() {
        do {
            container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            )
            context = ModelContext(container)
            
            previewModelContainer = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            
            actor = SwiftDataActor(modelContainer: container)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetch<T: PersistentModel>() async throws -> [T] {
        return try await fetch(sortBy: [])
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
    
    func fetchUnsyncedEntities() throws -> [any PersistentModel] {
        var unsyncedEntities: [any PersistentModel] = []
        
        let vehicleDescriptor =
            FetchDescriptor<Vehicle>(predicate: #Predicate { vehicle in
                !vehicle.synced
        })
        let vehicles = try SwiftDataManager.shared.context.fetch(vehicleDescriptor)
        
        let vehicleMileageDescriptor =
            FetchDescriptor<VehicleMileage>(predicate: #Predicate { vehicleMileage in
                !vehicleMileage.synced
        })
        let vehicleMileages = try SwiftDataManager.shared.context.fetch(vehicleMileageDescriptor)
        
        unsyncedEntities.append(contentsOf: vehicles)
        unsyncedEntities.append(contentsOf: vehicleMileages)
        
        return unsyncedEntities
    }
    
    func save<T: PersistentModel>(id: String? = nil, item: T) async throws {
        try await actor.save(id: id, item: item)
    }
    
    func importData<T: PersistentModel>(_ data: [T]) async throws {
        try await actor.importData(data)
    }
}
