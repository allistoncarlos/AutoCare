//
//  ChangesDataSource.swift
//  AutoCare
//

import Foundation

protocol ChangesDataSourceProtocol {
    func fetchChanges(since: Date?) async -> ChangesResponse?
}

final class ChangesDataSource: ChangesDataSourceProtocol {
    func fetchChanges(since: Date?) async -> ChangesResponse? {
        let sinceValue = since.map { ISO8601DateFormatter().string(from: $0) }
        return await NetworkManager.shared.performRequest(
            responseType: ChangesResponse.self,
            endpoint: .changes(since: sinceValue)
        )
    }
}
