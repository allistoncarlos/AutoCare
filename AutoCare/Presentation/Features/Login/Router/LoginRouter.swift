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
    static func makeHomeView(modelContext: ModelContext) -> some View {
        return HomeView(viewModel: HomeView.ViewModel(modelContext: modelContext))
    }

    static func makeLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
