//
//  NetworkManager.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//


import Alamofire
import Foundation
import Pulse

public class NetworkManager {
    static let shared = NetworkManager()

    @discardableResult
    func performRequest<T: Decodable>(responseType: T.Type, endpoint: AutoCareAPI, cache: Bool = false) async -> T? {
        do {
            let request = sessionManager.request(endpoint)
                .validate(statusCode: 200 ... 300)
                .cacheResponse(using: cache ? .cache : .doNotCache)

            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            let response = try await request.serializingDecodable(T.self, decoder: jsonDecoder).value

            return response
        } catch {
            print(error)
            return nil
        }
    }

    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        let responseCacher = ResponseCacher(behavior: .modify { _, response in
            let userInfo = ["date": Date()]
            return CachedURLResponse(
                response: response.response,
                data: response.data,
                userInfo: userInfo,
                storagePolicy: .allowed
            )
        })

        let pulseLogger = NetworkLogger()
        let pulseNetworkLoggerEventMonitor = NetworkLoggerEventMonitor(logger: pulseLogger)

        let defaultEventMonitor = DefaultEventMonitor()
        let requestsInterceptor = DefaultRequestInterceptor()

        return Session(
            configuration: configuration,
            interceptor: requestsInterceptor,
            cachedResponseHandler: responseCacher,
            eventMonitors: [defaultEventMonitor, pulseNetworkLoggerEventMonitor]
        )
    }()

}
