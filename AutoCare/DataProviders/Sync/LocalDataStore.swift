//
//  LocalDataStore.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 07/07/26.
//

import Foundation
import SwiftData

@MainActor
struct LocalDataStore {
    let modelContext: ModelContext

    func fetch<T: PersistentModel>(sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }

    func fetch<T: PersistentModel>(where predicate: Predicate<T>, sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }

    func fetchOne<T: PersistentModel>(where predicate: Predicate<T>) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func insert<T: PersistentModel>(_ item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func markUnsynced<T: Syncable>(_ item: T) throws where T: PersistentModel {
        item.synced = false
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }
}
