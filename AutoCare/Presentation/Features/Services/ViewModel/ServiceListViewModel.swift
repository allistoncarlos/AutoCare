//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI
import Combine

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
        var realm: Realm? = nil
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        func setup(app: RealmSwift.App) async {
            self.app = app
        }
    }
}
