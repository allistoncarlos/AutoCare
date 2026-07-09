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
    static let userResource = "user"
    static let vehicleTypeResource = "vehicleType"
    static let vehicleResource = "vehicle"
    static let vehicleMileageResource = "vehicleMileage"
    static let vehicleServiceResource = "vehicleService"
}

// MARK: - AutoCareAPI

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
    case vehicleServices(vehicleId: String)
    case vehicleService(vehicleId: String, id: String)
    case saveVehicleService(id: String?, data: VehicleServiceRequest)

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

        case let .vehicleServices(vehicleId):
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleServiceResource)/\(vehicleId)"
        case let .vehicleService(vehicleId, id):
            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleServiceResource)/\(vehicleId)/\(id)"
        case let .saveVehicleService(id, _):
            if let id = id {
                return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleServiceResource)/\(id)"
            }

            return "\(AutoCareAPI.apiArea)/\(APIConstants.vehicleServiceResource)/"
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
             .vehicleService:
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

        case let .saveVehicleService(id, _):
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
        case let .saveVehicleService(_, model):
            return try parameterEncoder.encode(model, into: request)
        case .vehicleType,
             .vehicles,
             .vehicle,

             .vehicleMileages,
             .vehicleMileage,

             .vehicleServices,
             .vehicleService:
            return request
        }
    }

}

// MARK: URLRequestConvertible

extension AutoCareAPI: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let resultUrl = "\(baseURL)/\(path)"

        let url = try resultUrl.asURL()
        var request = URLRequest(url: url)
        request.method = method

        return try encodeParameters(into: request)
    }
}
