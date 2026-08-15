//
//  ServiceRoute.swift
//  AutoCare
//

import Foundation

enum ServiceRoute: Hashable {
    case new
    case edit(clientId: String)
}
