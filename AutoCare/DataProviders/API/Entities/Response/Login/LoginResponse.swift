//
//  LoginResponse.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Foundation

public struct LoginUserResponse: Codable {
    public var id: String
    public var username: String?
    public var firstName: String
    public var lastName: String
}

public struct LoginResponse: Codable {
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date
    public var user: LoginUserResponse

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}
