//
//  AutoCareWatchApp.swift
//  AutoCare Watch App
//

import SwiftUI

@main
struct AutoCareWatchApp: App {
    init() {
        WatchConnectivityManager.shared.activateSession()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
