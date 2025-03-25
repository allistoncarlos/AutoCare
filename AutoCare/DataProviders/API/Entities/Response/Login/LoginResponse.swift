//
//  LoginResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Foundation

public struct LoginResponse: Codable {
    public var id: String
    public var firstName: String
    public var lastName: String
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date

    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
