//
//  NetworkManager.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Foundation
import Factory

// MARK: - Encodable + Data pretty print helpers

extension Encodable {
    func prettyPrintJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let encodedData = try? encoder.encode(self) else {
            return nil
        }

        return String(decoding: encodedData, as: UTF8.self)
    }
}

extension Data {
    func prettyPrintJSON() -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: self) else {
            return nil
        }

        guard let serializedData = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        ) else {
            return nil
        }

        return String(decoding: serializedData, as: UTF8.self)
    }
}

// MARK: - NetworkError

public enum NetworkError: Error {
    case httpCode(Int)
}

// MARK: - NetworkManager

public class NetworkManager {

    // MARK: Public

    public static let shared = NetworkManager()

    @discardableResult
    func performRequest<T: Decodable>(
        responseType: T.Type,
        endpoint: AutoCareAPI,
        cache: Bool = false,
        retryCount: Int = 0
    ) async -> T? {
        do {
            var urlRequest = try endpoint.asURLRequest()
            urlRequest.cachePolicy = cache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData

            if let accessToken = KeychainDataSource.accessToken.get() {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            print("ENDPOINT: /\(endpoint.method.rawValue) \(endpoint.path)")
            print("REQUEST: \n: \(urlRequest.httpBody?.prettyPrintJSON() ?? "")")

            let (data, response) = try await session.data(for: urlRequest)
            print("RESPONSE: \(data.prettyPrintJSON() ?? "")")

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            switch httpResponse.statusCode {
            case 200..<300:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)

            case 401 where retryCount < retryLimit && !endpoint.isRefreshToken:
                if await refreshTokens() {
                    return await performRequest(
                        responseType: responseType,
                        endpoint: endpoint,
                        cache: cache,
                        retryCount: retryCount + 1
                    )
                }

                await signOut()

            case 401:
                await signOut()

            case 500..<600 where retryCount < retryLimit:
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                return await performRequest(
                    responseType: responseType,
                    endpoint: endpoint,
                    cache: cache,
                    retryCount: retryCount + 1
                )

            default:
                throw NetworkError.httpCode(httpResponse.statusCode)
            }

        } catch {
            print(error)
            return nil
        }

        return nil
    }

    // MARK: Internal

    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()

    // MARK: Private

    private let retryLimit = 3
    private let retryDelay: TimeInterval = 10

    private func refreshTokens() async -> Bool {
        guard let refreshToken = KeychainDataSource.refreshToken.get() else {
            return false
        }

        guard let result = await performRequest(
            responseType: RefreshTokenResponse.self,
            endpoint: .refreshToken(data: RefreshTokenRequest(refreshToken: refreshToken))
        ) else {
            return false
        }

        let dateFormatter = ISO8601DateFormatter()
        let formattedExpiresIn = dateFormatter.string(from: result.expiresIn)

        KeychainDataSource.accessToken.set(result.accessToken)
        KeychainDataSource.refreshToken.set(result.refreshToken)
        KeychainDataSource.expiresIn.set(formattedExpiresIn)

        return true
    }

    private func signOut() async {
        await MainActor.run {
            Container.shared.authSessionStore().logout(clearLocalData: false)
        }
    }

}
