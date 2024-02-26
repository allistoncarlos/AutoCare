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

enum LoginError: Error, Equatable {
    case invalidUsernameOrPassword
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var state: LoginState = .idle
    
    private var app: RealmSwift.App?
    var realm: Realm? = nil
    
    func setup(app: RealmSwift.App) async {
        self.app = app
    }

    func login(email: String, password: String) async {
        state = .loading
        
        if app?.currentUser == nil {
            do {
                let credentials = Credentials.emailPassword(email: email, password: password)
                _ = try await app?.login(credentials: credentials)
                
                state = .success
            } catch {
                state = .error(.invalidUsernameOrPassword)
            }
        }
    }
}

extension LoginViewModel {
    @MainActor
    func homeView() -> some View {
        return LoginRouter.makeHomeView()
    }
}
