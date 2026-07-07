//
//  AutoCareViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/04/25.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

extension AutoCareApp {
    @MainActor
    final class ViewModel: ObservableObject {
        func resultView(modelContext: ModelContext) -> AnyView {
            KeychainDataSource.hasValidToken()
                ? AnyView(LoginRouter.makeHomeView(modelContext: modelContext))
                : AnyView(LoginRouter.makeLoginView())
        }
    }
}
