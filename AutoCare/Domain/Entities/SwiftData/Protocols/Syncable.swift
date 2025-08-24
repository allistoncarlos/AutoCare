//
//  Syncable.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//


import Foundation
import SwiftData

public protocol Syncable: PersistentModel {
    var synced: Bool { get set }
}
