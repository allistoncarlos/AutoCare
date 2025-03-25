//
//  LoginRequest.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

public struct LoginRequest: Codable {
    public var username: String
    public var password: String

    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
