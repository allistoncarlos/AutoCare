//
//  MileageEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI
import Combine

extension MileageEditView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var vehicleMileage: VehicleMileage
        
        init(vehicleMileage: VehicleMileage) {
            self.vehicleMileage = vehicleMileage
        }
    }
}
