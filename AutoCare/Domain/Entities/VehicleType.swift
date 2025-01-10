//
//  VehicleType.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import Foundation
import RealmSwift

class VehicleType: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var enabled: Bool = true
    
    convenience init(name: String, enabled: Bool = true) {
        self.init()
        self.name = name
        self.enabled = enabled
    }
    
    func localizedName() -> String {
        return switch name {
        case "Bike": "🏍️"
        case "Car": "🏎️"
        case "Truck": "🚚"
        default: ""
        }
    }
}
