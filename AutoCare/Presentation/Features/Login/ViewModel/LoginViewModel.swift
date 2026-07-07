//
//  LoginViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 20/02/24.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

enum LoginError: Error, Equatable {
    case invalidUsernameOrPassword
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var state: LoginState = .idle
    @Injected(\.loginRepository) private var repository: LoginRepositoryProtocol

    func login(username: String, password: String) async {
        state = .loading

        let result = await repository.login(login: Login(username: username, password: password))

        if let result {
            saveToken(response: result)
            state = .success(result)
        } else {
            state = .error(.invalidUsernameOrPassword)
        }
    }

    func homeView(modelContext: ModelContext) -> some View {
        LoginRouter.makeHomeView(modelContext: modelContext)
    }

    private func saveToken(response: Login?) {
        if let session = response,
           let id = session.id,
           let accessToken = session.accessToken,
           let refreshToken = session.refreshToken,
           let expiresIn = session.expiresIn {
            let dateFormatter = ISO8601DateFormatter()
            let formattedExpiresIn = dateFormatter.string(from: expiresIn)

            KeychainDataSource.id.set(id)
            KeychainDataSource.accessToken.set(accessToken)
            KeychainDataSource.refreshToken.set(refreshToken)
            KeychainDataSource.expiresIn.set(formattedExpiresIn)
        } else {
            KeychainDataSource.clear()
        }
    }
}
