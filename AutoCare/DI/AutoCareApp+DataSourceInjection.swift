//
//  AutoCareApp+DataSourceInjection.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 25/03/25.
//

import Factory
import Foundation

extension Container {
    var loginDataSource: Factory<LoginDataSourceProtocol> { self { LoginDataSource() } }
}
