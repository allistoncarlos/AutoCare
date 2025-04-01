//
//  SwiftDataManager.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 01/04/25.
//

import SwiftData

final class SwiftDataManager {
    let schema = Schema([
        VehicleType.self,
        Vehicle.self,
        VehicleMileage.self
    ])
    
    let container: ModelContainer
    let previewModelContext: ModelContext

    static let shared = SwiftDataManager()
    
    private init() {
        do {
            container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            )
            
            previewModelContext = ModelContext(
                try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
