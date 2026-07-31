//
//  MileageRoute.swift
//  AutoCare
//

import Foundation

enum MileageRoute: Hashable {
    case new
    case edit(clientId: String)
}
