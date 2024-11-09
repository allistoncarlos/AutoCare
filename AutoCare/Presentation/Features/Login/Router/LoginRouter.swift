//
//  LoginRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/02/24.
//

import SwiftUI

@MainActor
enum LoginRouter {
    static func makeHomeView() -> some View {
//        return MileageListView(viewModel: MileageListView.ViewModel())
        return HomeView(mileageListViewViewModel: MileageListView.ViewModel())
    }

    static func makeLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
