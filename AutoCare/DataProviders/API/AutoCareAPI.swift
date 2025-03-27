//
//  AutoCareAPI.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Alamofire
import Foundation

internal enum APIConstants {
    static let userResource = "user"
    static let vehicleResource = "vehicle"
}

public enum AutoCareAPI {
    private static let apiArea = "autocare"
    
    case login(data: LoginRequest)
    case refreshToken(data: RefreshTokenRequest)
    case vehicles
    case vehicle(id: String)

    var baseURL: String {
        switch self {
        default:
            return Config.apiPath
        }
    }

    var path: String {
        switch self {
        case .login:
            return "\(APIConstants.userResource)/login"
        case .refreshToken:
            return "\(APIConstants.userResource)/refresh"
            
        case .vehicles:
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleResource)"
        case let .vehicle(id):
            return "\(AutoCareAPI.apiArea)\(APIConstants.vehicleResource)/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .vehicles,
             .vehicle:
            return .get
        case .login,
             .refreshToken:
            return .post
        }
    }

    var parameterEncoder: ParameterEncoder {
        switch method {
        case .get: return URLEncodedFormParameterEncoder()
        default:
            let encoder = JSONParameterEncoder()
            encoder.encoder.dateEncodingStrategy = .iso8601
            return encoder
        }
    }

    var isRefreshToken: Bool {
        switch self {
        case .refreshToken:
            return true
        default:
            return false
        }
    }

    func encodeParameters(into request: URLRequest) throws -> URLRequest {
        switch self {
        case let .login(parameters):
            return try parameterEncoder.encode(parameters, into: request)
        case let .refreshToken(parameters):
            return try parameterEncoder.encode(parameters, into: request)
        case .vehicles,
             .vehicle:
            return request
        }
    }

}

extension AutoCareAPI: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let resultUrl = "\(baseURL)/\(path)"

        let url = try resultUrl.asURL()
        var request = URLRequest(url: url)
        request.method = method

        return try encodeParameters(into: request)
    }
}
