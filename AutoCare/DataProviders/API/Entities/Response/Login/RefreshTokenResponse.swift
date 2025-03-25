//
//  RefreshTokenResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//


import Foundation

public struct RefreshTokenResponse: Codable {
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
