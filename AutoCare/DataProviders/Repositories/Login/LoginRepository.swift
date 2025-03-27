//
//  LoginRepository.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Foundation
import Factory

protocol LoginRepositoryProtocol {
    func login(login: Login) async -> Login?
}

struct LoginRepository: LoginRepositoryProtocol {
    func login(login: Login) async -> Login? {
        do {return await dataSource.login(loginRequest: try login.toRequest())
        } catch {
            print(error)
            return nil
        }
    }

    @Injected(\.loginDataSource) var dataSource: LoginDataSourceProtocol
}
