//
//  ServiceEditState.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 15/08/26.
//

import Foundation

enum ServiceEditState: Equatable {
    case idle
    case loading
    case error
    case successSave
}
