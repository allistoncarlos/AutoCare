//
//  WatchConnectivityMessages.swift
//  AutoCare
//

import Foundation

enum WatchMessageKey {
    static let checkAuth = "CHECK_AUTH"
    static let authStatus = "AUTH_STATUS"
    static let fetchVehicles = "FETCH_VEHICLES"
    static let vehicles = "VEHICLES"
    static let saveMileage = "SAVE_MILEAGE"
    static let mileageSaved = "MILEAGE_SAVED"
    static let error = "ERROR"
}

enum WatchAuthStatus: String, Codable {
    case logged = "LOGGED"
    case notLogged = "NOT_LOGGED"
}

struct WatchVehicle: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let isDefault: Bool
    let lastOdometer: Int?
    let lastFuelCost: Double?
    let lastTotalCost: Double?
    let lastLiters: Double?
}

struct WatchVehiclesPayload: Codable, Equatable {
    let vehicles: [WatchVehicle]
}

struct WatchSaveMileageRequest: Codable {
    let vehicleId: String
    let totalCost: Double
    let fuelCost: Double
    let liters: Double
    let odometer: Int
    let complete: Bool
    let dateISO: String?
}

struct WatchMileageSavedPayload: Codable {
    let success: Bool
    let odometerDifference: Int
    let calculatedMileage: Double
}

enum WatchConnectivityPayloadCodec {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }

    static func reply<T: Encodable>(_ key: String, value: T) -> [String: Any]? {
        guard let data = encode(value) else { return nil }
        return [key: data]
    }
}

enum WatchConnectivityDateCodec {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func isoString(from date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(fromISO string: String) -> Date? {
        formatter.date(from: string) ?? fallbackFormatter.date(from: string)
    }
}
