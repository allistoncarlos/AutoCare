//
//  LoginViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 20/02/24.
//

import Combine
import Factory
import Foundation
import SwiftUI

enum LoginError: Error, Equatable {
    case invalidUsernameOrPassword
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var state: LoginState = .idle
    @Injected(\.loginRepository) private var repository
    @Injected(\.authSessionStore) private var authSession

    func login(username: String, password: String) async {
        state = .loading

        let result = await repository.login(login: Login(username: username, password: password))

        if let result {
            saveToken(response: result)

            guard KeychainDataSource.hasValidToken() else {
                authSession.logout(clearLocalData: false)
                state = .error(.invalidUsernameOrPassword)
                return
            }

            authSession.markAuthenticated()
            state = .success(result)
        } else {
            state = .error(.invalidUsernameOrPassword)
        }
    }

    private func saveToken(response: Login) {
        let dateFormatter = ISO8601DateFormatter()
        let formattedExpiresIn = dateFormatter.string(from: response.expiresIn ?? Date())

        guard
            let id = response.id, !id.isEmpty,
            let accessToken = response.accessToken, !accessToken.isEmpty,
            let refreshToken = response.refreshToken, !refreshToken.isEmpty,
            response.expiresIn != nil
        else {
            KeychainDataSource.clear()
            return
        }

        KeychainDataSource.id.set(id)
        KeychainDataSource.accessToken.set(accessToken)
        KeychainDataSource.refreshToken.set(refreshToken)
        KeychainDataSource.expiresIn.set(formattedExpiresIn)
    }
}
