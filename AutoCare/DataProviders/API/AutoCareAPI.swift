//
//  AutoCareAPI.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - ParameterEncoder

protocol ParameterEncoder {
    func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest
}

class JSONParameterEncoder: ParameterEncoder {
    let encoder: JSONEncoder

    init() {
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var urlRequest = request

        let data = try encoder.encode(parameters)
        urlRequest.httpBody = data

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}

class URLEncodedFormParameterEncoder: ParameterEncoder {
    init() {}

    func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var urlRequest = request

        if request.httpMethod != "GET" {
            let data = try JSONEncoder().encode(parameters)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

            let formData = dictionary.compactMap { key, value -> String? in
                guard let encodedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    return nil
                }
                return "\(encodedKey)=\(encodedValue)"
            }.joined(separator: "&")

            urlRequest.httpBody = formData.data(using: .utf8)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }

        return urlRequest
    }
}

// MARK: - URLRequestConvertible

protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

extension String {
    func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw URLError(.badURL)
        }
        return url
    }
}

extension URLRequest {
    var method: HTTPMethod? {
        get {
            guard let httpMethod = httpMethod else { return nil }
            return HTTPMethod(rawValue: httpMethod)
        }
        set {
            httpMethod = newValue?.rawValue
        }
    }
}

// MARK: - APIConstants

enum APIConstants {
    static let authResource = "auth"
    static let changesResource = "changes"
    static let vehicleTypeResource = "vehicle-type"
    static let vehicleResource = "vehicle"
    static let vehicleMileageResource = "vehicle-mileage"
    static let vehicleServiceResource = "vehicle-service"
}

// MARK: - AutoCareAPI

enum AutoCareAPI {
    case login(data: LoginRequest)
    case refreshToken(data: RefreshTokenRequest)
    case changes(since: String?)
    case vehicleType
    case vehicles
    case vehicle(id: String)
    case saveVehicle(data: VehicleRequest, serverId: String?)
    case vehicleMileages(vehicleId: String)
    case vehicleMileage(id: String)
    case saveVehicleMileage(data: VehicleMileageRequest, serverId: String?)
    case vehicleServices(vehicleId: String)
    case vehicleService(id: String)
    case saveVehicleService(data: VehicleServiceRequest, serverId: String?)
    case deleteVehicleService(clientId: String)

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
        case let .saveVehicle(data, serverId):
            if serverId != nil {
                return "\(APIConstants.vehicleResource)/\(data.clientId)"
            }
            return APIConstants.vehicleResource
        case .vehicleMileages:
            return APIConstants.vehicleMileageResource
        case let .vehicleMileage(id):
            return "\(APIConstants.vehicleMileageResource)/\(id)"
        case let .saveVehicleMileage(data, serverId):
            if serverId != nil {
                return "\(APIConstants.vehicleMileageResource)/\(data.clientId)"
            }
            return APIConstants.vehicleMileageResource
        case .vehicleServices:
            return APIConstants.vehicleServiceResource
        case let .vehicleService(id):
            return "\(APIConstants.vehicleServiceResource)/\(id)"
        case let .saveVehicleService(data, serverId):
            if serverId != nil {
                return "\(APIConstants.vehicleServiceResource)/\(data.clientId)"
            }
            return APIConstants.vehicleServiceResource
        case let .deleteVehicleService(clientId):
            return "\(APIConstants.vehicleServiceResource)/\(clientId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .vehicleType,
             .vehicles,
             .vehicle,
             .vehicleMileages,
             .vehicleMileage,
             .vehicleServices,
             .vehicleService,
             .changes:
            return .get
        case .login, .refreshToken:
            return .post
        case let .saveVehicle(_, serverId):
            return serverId == nil ? .post : .put
        case let .saveVehicleMileage(_, serverId):
            return serverId == nil ? .post : .put
        case let .saveVehicleService(_, serverId):
            return serverId == nil ? .post : .put
        case .deleteVehicleService:
            return .delete
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
        case let .saveVehicle(data, _):
            return try parameterEncoder.encode(data, into: request)
        case let .saveVehicleMileage(data, _):
            return try parameterEncoder.encode(data, into: request)
        case let .saveVehicleService(data, _):
            return try parameterEncoder.encode(data, into: request)
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
        case .vehicleType, .vehicles, .vehicle, .vehicleMileage, .vehicleService, .deleteVehicleService:
            return request
        }
    }
}

// MARK: URLRequestConvertible

extension AutoCareAPI: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let resultUrl = "\(baseURL)/\(path)"
        let url = try resultUrl.asURL()
        var request = URLRequest(url: url)
        request.method = method
        return try encodeParameters(into: request)
    }
}
