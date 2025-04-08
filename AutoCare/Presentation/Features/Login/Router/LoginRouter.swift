//
//  LoginRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/02/24.
//

import SwiftUI
import SwiftData

@MainActor
enum LoginRouter {
    static func makeHomeView(modelContainer: ModelContainer) -> some View {
        return HomeView(
            viewModel: HomeView.ViewModel(modelContainer: modelContainer)
        )
    }

    static func makeLoginView(modelContainer: ModelContainer) -> some View {
        return LoginView(
            viewModel: LoginViewModel(),
            modelContainer: modelContainer
        )
    }
}
