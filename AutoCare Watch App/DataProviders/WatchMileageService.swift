//
//  WatchMileageService.swift
//  AutoCare Watch App
//

import Foundation

enum WatchMileageServiceError: LocalizedError {
    case notLogged
    case unreachable
    case saveFailed
    case decodeFailed
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .notLogged:
            return "Faça login no iPhone"
        case .unreachable:
            return "iPhone indisponível"
        case .saveFailed:
            return "Falha ao salvar"
        case .decodeFailed:
            return "Resposta inválida"
        case let .underlying(error):
            return error.localizedDescription
        }
    }
}

@MainActor
final class WatchMileageService {
    func checkAuth() async throws {
        let connectivity = WatchConnectivityManager.shared
        await connectivity.waitForActivation()

        if connectivity.cachedAuthStatus == .logged {
            return
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task { @MainActor in
                await connectivity.sendMessageWithTimeout(
                    key: WatchMessageKey.checkAuth,
                    replyHandler: { reply in
                        Task { @MainActor in
                            if let statusRaw = reply[WatchMessageKey.authStatus] as? String,
                               let status = WatchAuthStatus(rawValue: statusRaw) {
                                connectivity.updateAuthStatus(status)
                                if status == .logged {
                                    continuation.resume()
                                } else {
                                    continuation.resume(throwing: WatchMileageServiceError.notLogged)
                                }
                                return
                            }
                            continuation.resume(throwing: WatchMileageServiceError.decodeFailed)
                        }
                    },
                    errorHandler: { error in
                        Task { @MainActor in
                            if connectivity.cachedAuthStatus == .logged {
                                continuation.resume()
                            } else {
                                continuation.resume(throwing: WatchMileageServiceError.underlying(error))
                            }
                        }
                    }
                )
            }
        }
    }

    func fetchVehicles(forceRefresh: Bool = false) async throws -> [WatchVehicle] {
        let connectivity = WatchConnectivityManager.shared
        await connectivity.waitForActivation()
        connectivity.refreshCachedPayload()

        if !forceRefresh, let cached = connectivity.cachedPayload?.vehicles {
            return cached
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[WatchVehicle], Error>) in
            Task { @MainActor in
                await connectivity.sendMessageWithTimeout(
                    key: WatchMessageKey.fetchVehicles,
                    replyHandler: { reply in
                        Task { @MainActor in
                            if let statusRaw = reply[WatchMessageKey.authStatus] as? String,
                               WatchAuthStatus(rawValue: statusRaw) == .notLogged {
                                continuation.resume(throwing: WatchMileageServiceError.notLogged)
                                return
                            }

                            if let data = reply[WatchMessageKey.vehicles] as? Data,
                               let payload = WatchConnectivityPayloadCodec.decode(WatchVehiclesPayload.self, from: data) {
                                connectivity.persistPayload(payload)
                                connectivity.updateAuthStatus(.logged)
                                continuation.resume(returning: payload.vehicles)
                                return
                            }

                            if let cached = connectivity.cachedPayload?.vehicles {
                                continuation.resume(returning: cached)
                                return
                            }

                            continuation.resume(throwing: WatchMileageServiceError.decodeFailed)
                        }
                    },
                    errorHandler: { error in
                        Task { @MainActor in
                            if let cached = connectivity.cachedPayload?.vehicles {
                                continuation.resume(returning: cached)
                            } else {
                                continuation.resume(throwing: WatchMileageServiceError.underlying(error))
                            }
                        }
                    }
                )
            }
        }
    }

    func saveMileage(_ request: WatchSaveMileageRequest) async throws -> WatchMileageSavedPayload {
        let connectivity = WatchConnectivityManager.shared
        await connectivity.waitForActivation()

        guard let data = WatchConnectivityPayloadCodec.encode(request) else {
            throw WatchMileageServiceError.decodeFailed
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<WatchMileageSavedPayload, Error>) in
            Task { @MainActor in
                await connectivity.sendMessageWithTimeout(
                    message: data,
                    key: WatchMessageKey.saveMileage,
                    timeout: 12,
                    replyHandler: { reply in
                        if let statusRaw = reply[WatchMessageKey.authStatus] as? String,
                           WatchAuthStatus(rawValue: statusRaw) == .notLogged {
                            continuation.resume(throwing: WatchMileageServiceError.notLogged)
                            return
                        }

                        if reply[WatchMessageKey.error] != nil {
                            continuation.resume(throwing: WatchMileageServiceError.saveFailed)
                            return
                        }

                        if let payloadData = reply[WatchMessageKey.mileageSaved] as? Data,
                           let payload = WatchConnectivityPayloadCodec.decode(
                            WatchMileageSavedPayload.self,
                            from: payloadData
                           ) {
                            continuation.resume(returning: payload)
                            return
                        }

                        continuation.resume(throwing: WatchMileageServiceError.decodeFailed)
                    },
                    errorHandler: { error in
                        continuation.resume(throwing: WatchMileageServiceError.underlying(error))
                    }
                )
            }
        }
    }
}
