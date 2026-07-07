//
//  LoginRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/02/24.
//

import SwiftData
import SwiftUI

@MainActor
enum LoginRouter {
    static func makeHomeView(modelContext: ModelContext) -> some View {
        HomeView(viewModel: HomeView.ViewModel(modelContext: modelContext))
    }

    static func makeLoginView() -> some View {
        LoginView(viewModel: LoginViewModel())
    }
}
