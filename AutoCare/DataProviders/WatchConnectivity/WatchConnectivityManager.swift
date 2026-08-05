//
//  WatchConnectivityManager.swift
//  AutoCare
//

#if canImport(WatchConnectivity)
import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var context: [String: Any] = [:]
    @Published var message: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated

    override private init() {
        super.init()
    }

    func activateSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        self.message = message
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        self.message = message

        #if os(iOS)
        Task { @MainActor in
            let reply = await WatchPhoneCoordinator.shared.handle(message: message)
            replyHandler(reply)
        }
        #else
        replyHandler([:])
        #endif
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        state = activationState

        #if os(iOS)
        if activationState == .activated {
            Task { @MainActor in
                await WatchPhoneCoordinator.shared.pushVehiclesToWatch()
            }
        }
        #endif
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        context = applicationContext
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
#endif
