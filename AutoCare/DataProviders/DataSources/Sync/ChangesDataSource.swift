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
        let sinceValue: String?
        if let since {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            sinceValue = formatter.string(from: since)
        } else {
            sinceValue = nil
        }

        return await NetworkManager.shared.performRequest(
            responseType: ChangesResponse.self,
            endpoint: .changes(since: sinceValue)
        )
    }
}
