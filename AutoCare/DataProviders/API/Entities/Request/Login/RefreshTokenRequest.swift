//
//  RefreshTokenRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

public struct RefreshTokenRequest: Codable {
    public var accessToken: String
    public var refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
