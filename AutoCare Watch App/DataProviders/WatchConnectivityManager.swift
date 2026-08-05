//
//  WatchConnectivityManager.swift
//  AutoCare Watch App
//

import Foundation
import WatchConnectivity

private enum WatchVehiclesCache {
    private static let fileName = "watch-vehicles.json"

    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent(fileName)
    }

    static func load() -> WatchVehiclesPayload? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WatchVehiclesPayload.self, from: data)
    }

    static func save(_ payload: WatchVehiclesPayload) {
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var context: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated
    @Published private(set) var isReachable = false
    @Published private(set) var cachedPayload: WatchVehiclesPayload?
    @Published private(set) var cachedAuthStatus: WatchAuthStatus?

    private var activationContinuations: [CheckedContinuation<Void, Never>] = []

    override private init() {
        super.init()
    }

    func activateSession() {
        guard WCSession.isSupported() else { return }

        if WCSession.default.activationState == .activated {
            state = .activated
            isReachable = WCSession.default.isReachable
            refreshCachedPayload()
            return
        }

        WCSession.default.delegate = self
        WCSession.default.activate()
        refreshCachedPayload()
    }

    func waitForActivation(timeoutSeconds: Double = 2) async {
        if WCSession.default.activationState == .activated {
            state = .activated
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            activationContinuations.append(continuation)

            Task { @MainActor in
                let steps = Int(timeoutSeconds * 10)
                for _ in 0..<steps {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    if WCSession.default.activationState == .activated {
                        finishActivation()
                        return
                    }
                }
                finishActivation()
            }
        }
    }

    func sendMessage(
        message: Any = true,
        key: String,
        replyHandler: (([String: Any]) -> Void)?,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        guard WCSession.default.activationState == .activated else {
            errorHandler?(WCError(.sessionNotActivated))
            return
        }

        guard WCSession.default.isCompanionAppInstalled else {
            errorHandler?(WCError(.companionAppNotInstalled))
            return
        }

        guard WCSession.default.isReachable else {
            errorHandler?(WCError(.notReachable))
            return
        }

        WCSession.default.sendMessage(
            [key: message],
            replyHandler: replyHandler,
            errorHandler: { error in
                errorHandler?(error)
            }
        )
    }

    func sendMessageWithTimeout(
        message: Any = true,
        key: String,
        timeout: TimeInterval = 8,
        replyHandler: @escaping ([String: Any]) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var didFinish = false

            func finish(_ block: () -> Void) {
                guard !didFinish else { return }
                didFinish = true
                block()
                continuation.resume()
            }

            sendMessage(
                message: message,
                key: key,
                replyHandler: { reply in
                    finish { replyHandler(reply) }
                },
                errorHandler: { error in
                    finish { errorHandler(error) }
                }
            )

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                finish { errorHandler(WCError(.notReachable)) }
            }
        }
    }

    func persistPayload(_ payload: WatchVehiclesPayload) {
        cachedPayload = payload
        WatchVehiclesCache.save(payload)
    }

    func updateAuthStatus(_ status: WatchAuthStatus) {
        cachedAuthStatus = status
    }

    func refreshCachedPayload() {
        let applicationContext = WCSession.default.receivedApplicationContext
        let mergedContext = applicationContext.isEmpty ? context : applicationContext

        if let statusRaw = mergedContext[WatchMessageKey.authStatus] as? String,
           let status = WatchAuthStatus(rawValue: statusRaw) {
            cachedAuthStatus = status
        }

        if let data = mergedContext[WatchMessageKey.vehicles] as? Data,
           let payload = WatchConnectivityPayloadCodec.decode(WatchVehiclesPayload.self, from: data) {
            cachedPayload = payload
            WatchVehiclesCache.save(payload)
        } else if let diskPayload = WatchVehiclesCache.load() {
            cachedPayload = diskPayload
        }
    }

    func vehiclesFromContext() -> WatchVehiclesPayload? {
        refreshCachedPayload()
        return cachedPayload
    }

    private func finishActivation() {
        state = WCSession.default.activationState
        isReachable = WCSession.default.isReachable

        let pending = activationContinuations
        activationContinuations.removeAll()
        pending.forEach { $0.resume() }

        refreshCachedPayload()
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            state = activationState
            isReachable = session.isReachable
            finishActivation()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isReachable = session.isReachable
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in
            context = applicationContext
            refreshCachedPayload()
        }
    }
}
