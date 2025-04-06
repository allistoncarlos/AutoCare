//
//  VehicleType.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation
import SwiftData

@Model
final class VehicleType: Syncable, Sendable {
    var id: String
    var name: String
    var emoji: String
    
    var synced: Bool
    
    init(
        id: String,
        name: String,
        emoji: String,
        
        synced: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        
        self.synced = synced
    }
}
