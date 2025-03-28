//
//  LoginViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 20/02/24.
//

import Foundation
import Realm
import RealmSwift
import SwiftUI
import Combine
import Factory
import SwiftData

enum LoginError: Error, Equatable {
    case invalidUsernameOrPassword
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var state: LoginState = .idle
    
    private var app: RealmSwift.App?
    var realm: Realm? = nil
    
    @Injected(\.loginRepository) private var repository: LoginRepositoryProtocol
    private var cancellable = Set<AnyCancellable>()
    
    func setup(app: RealmSwift.App) async {
        self.app = app
    }
    
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

extension LoginViewModel {
    @MainActor
    func homeView(modelContext: ModelContext) -> some View {
        return LoginRouter.makeHomeView(modelContext: modelContext)
    }
}
