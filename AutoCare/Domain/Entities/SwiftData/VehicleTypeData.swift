//
//  VehicleTypeData.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 26/03/25.
//

import Foundation
import SwiftData

@Model
final class VehicleTypeData {
    var id: String = ""
    var name: String = ""
    var emoji: String = ""
    
    init(
        id: String,
        name: String,
        emoji: String
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}
