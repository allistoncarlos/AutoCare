//
//  LoginDataSource.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

protocol LoginDataSourceProtocol {
    func login(loginRequest: LoginRequest) async -> Login?
}

class LoginDataSource: LoginDataSourceProtocol {
    func login(loginRequest: LoginRequest) async -> Login? {
        if let result = await NetworkManager.shared
            .performRequest(
                responseType: LoginResponse.self,
                endpoint: .login(data: loginRequest)
            ) {
            return result.toLogin()
        }

        return nil
    }
}
