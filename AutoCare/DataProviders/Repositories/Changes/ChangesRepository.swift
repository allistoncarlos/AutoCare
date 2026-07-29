//
//  ChangesRepository.swift
//  AutoCare
//

import Factory
import Foundation

protocol ChangesRepositoryProtocol {
    func fetchChanges(since: Date?) async -> ChangesResponse?
}

struct ChangesRepository: ChangesRepositoryProtocol {
    func fetchChanges(since: Date?) async -> ChangesResponse? {
        await dataSource.fetchChanges(since: since)
    }

    @Injected(\.changesDataSource) var dataSource: ChangesDataSourceProtocol
}
