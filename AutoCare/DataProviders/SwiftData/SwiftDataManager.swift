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
    func save<T: PersistentModel>(id: String? = nil, item: T) {
        do {
            if let id {
                try update(id: id, item: item)
            } else {
                try insert(item: item)
            }
            
            try? modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func importData<T: PersistentModel>(_ data: [T]) throws {
        try modelContext.delete(model: T.self)
        
        data.forEach { item in
            save(item: item)
        }
    }
    
    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        
        let result = try modelContext.fetch(descriptor)
        
        return result
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
    
    func save<T: PersistentModel>(id: String? = nil, item: T) async {
        await actor.save(id: id, item: item)
    }
    
//    func importData<T: PersistentModel>(_ data: [T]) throws {
//        try SwiftDataManager.shared.context.delete(model: T.self)
//        
//        data.forEach { item in
//            SwiftDataManager.shared.context.insert(item)
//        }
//    }
    func importData<T: PersistentModel>(_ data: [T]) async throws {
        try await actor.importData(data)
    }
    
    // TODO: Será se essa func precisa mesmo? o que ela tá syncando?
//    func syncData() async throws {
//        self.schema.entities.forEach { element in
//            print(element)
//        }
//    }
    
    
    
//    private func createUpdateDescriptor<T: PersistentModel>(for id: String) -> FetchDescriptor<T> {
//        var descriptor = FetchDescriptor<T>(predicate: #Predicate { item in
//            item.id == id
//        })
//        
//        descriptor.fetchLimit = 1
//        
//        return descriptor
//    }
}
