//
//  LoginState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 20/02/24.
//

import Foundation

enum LoginState: Equatable {
    case idle
    case loading
    case success(Login)
    case error(LoginError)
}
