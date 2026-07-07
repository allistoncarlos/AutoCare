//
//  AutoCareAPI.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Alamofire
import Foundation

enum APIConstants {
    static let authResource = "auth"
    static let changesResource = "changes"
    static let vehicleTypeResource = "vehicle-type"
    static let vehicleResource = "vehicle"
    static let vehicleMileageResource = "vehicle-mileage"
    static let vehicleServiceResource = "vehicle-service"
}

enum AutoCareAPI {
    case login(data: LoginRequest)
    case refreshToken(data: RefreshTokenRequest)
    case changes(since: String?)
    case vehicleType
    case vehicles
    case vehicle(id: String)
    case saveVehicle(id: String?, data: VehicleRequest)
    case vehicleMileages(vehicleId: String)
    case vehicleMileage(id: String)
    case saveVehicleMileage(id: String?, data: VehicleMileageRequest)
    case vehicleServices(vehicleId: String)
    case vehicleService(id: String)
    case saveVehicleService(id: String?, data: VehicleServiceRequest)

    var baseURL: String {
        Config.apiPath
    }

    var path: String {
        switch self {
        case .login:
            return "\(APIConstants.authResource)/login"
        case .refreshToken:
            return "\(APIConstants.authResource)/refresh"
        case .changes:
            return APIConstants.changesResource
        case .vehicleType:
            return APIConstants.vehicleTypeResource
        case .vehicles:
            return APIConstants.vehicleResource
        case let .vehicle(id):
            return "\(APIConstants.vehicleResource)/\(id)"
        case let .saveVehicle(id, _):
            if let id {
                return "\(APIConstants.vehicleResource)/\(id)"
            }
            return "\(APIConstants.vehicleResource)"
        case .vehicleMileages:
            return APIConstants.vehicleMileageResource
        case let .vehicleMileage(id):
            return "\(APIConstants.vehicleMileageResource)/\(id)"
        case let .saveVehicleMileage(id, _):
            if let id {
                return "\(APIConstants.vehicleMileageResource)/\(id)"
            }
            return APIConstants.vehicleMileageResource
        case .vehicleServices:
            return APIConstants.vehicleServiceResource
        case let .vehicleService(id):
            return "\(APIConstants.vehicleServiceResource)/\(id)"
        case let .saveVehicleService(id, _):
            if let id {
                return "\(APIConstants.vehicleServiceResource)/\(id)"
            }
            return APIConstants.vehicleServiceResource
        }
    }

    var method: HTTPMethod {
        switch self {
        case .vehicleType, .vehicles, .vehicle, .vehicleMileages, .vehicleMileage, .vehicleServices, .vehicleService, .changes:
            return .get
        case .login, .refreshToken:
            return .post
        case let .saveVehicle(id, _):
            return id == nil ? .post : .put
        case let .saveVehicleMileage(id, _):
            return id == nil ? .post : .put
        case let .saveVehicleService(id, _):
            return id == nil ? .post : .put
        }
    }

    var parameterEncoder: ParameterEncoder {
        switch method {
        case .get:
            return URLEncodedFormParameterEncoder()
        default:
            let encoder = JSONParameterEncoder()
            encoder.encoder.dateEncodingStrategy = .iso8601
            return encoder
        }
    }

    var isRefreshToken: Bool {
        if case .refreshToken = self { return true }
        return false
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
        case let .saveVehicleService(_, model):
            return try parameterEncoder.encode(model, into: request)
        case let .changes(since):
            guard let since else { return request }
            var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "since", value: since)]
            guard let url = components?.url else { return request }
            var updated = request
            updated.url = url
            return updated
        case let .vehicleMileages(vehicleId):
            var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "vehicleId", value: vehicleId)]
            guard let url = components?.url else { return request }
            var updated = request
            updated.url = url
            return updated
        case let .vehicleServices(vehicleId):
            var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "vehicleId", value: vehicleId)]
            guard let url = components?.url else { return request }
            var updated = request
            updated.url = url
            return updated
        case .vehicleType, .vehicles, .vehicle, .vehicleMileage, .vehicleService:
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
