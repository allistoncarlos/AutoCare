//
//  AutoCareAPI.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Alamofire
import Foundation

enum APIConstants {
    static let userResource = "user"
    static let vehicleTypeResource = "vehicleType"
    static let vehicleResource = "vehicle"
    static let vehicleMileageResource = "vehicleMileage"
}

enum AutoCareAPI {
    private static let apiArea = "autocare"
    
    case login(data: LoginRequest)
    case refreshToken(data: RefreshTokenRequest)
    case vehicleType
    case vehicles
    case vehicle(id: String)
    case saveVehicle(id: String?, data: VehicleRequest)
    case vehicleMileages(vehicleId: String)
    case vehicleMileage(vehicleId: String, id: String)
    case saveVehicleMileage(id: String?, data: VehicleMileageRequest)

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
            
        case .vehicleType:
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleTypeResource)"
            
        case .vehicles:
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleResource)"
        case let .vehicle(id):
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleResource)/\(id)"
        case let .saveVehicle(id, _):
            if let id = id {
                return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleResource)/\(id)"
            }

            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleResource)/"
            
        case let .vehicleMileages(vehicleId):
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleMileageResource)/\(vehicleId)"
        case let .vehicleMileage(vehicleId, id):
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleMileageResource)/\(vehicleId)/\(id)"
        case let .saveVehicleMileage(id, _):
            if let id = id {
                return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleMileageResource)/\(id)"
            }

            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleMileageResource)/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .vehicleType,
             .vehicles,
             .vehicle,
            
             .vehicleMileages,
             .vehicleMileage:
            return .get
        case .login,
             .refreshToken:
            return .post
            
        case let .saveVehicle(id, _):
            if id != nil {
                return .put
            }

            return .post
            
        case let .saveVehicleMileage(id, _):
            if id != nil {
                return .put
            }

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
        case let .saveVehicle(_, model):
            return try parameterEncoder.encode(model, into: request)
        case let .saveVehicleMileage(_, model):
            return try parameterEncoder.encode(model, into: request)
        case .vehicleType,
             .vehicles,
             .vehicle,
            
             .vehicleMileages,
             .vehicleMileage:
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
