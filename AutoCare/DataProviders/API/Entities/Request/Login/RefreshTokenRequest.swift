//
//  RefreshTokenRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

public struct RefreshTokenRequest: Codable, Sendable {
    public var refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
