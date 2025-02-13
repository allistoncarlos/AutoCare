//
//  ServiceListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI

import SwiftUI
import Realm
import TTProgressHUD
import RealmSwift

struct ServiceListView: View {
    @EnvironmentObject var app: RLMApp
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text("Hello, world!")
    }
}

#Preview {
    ServiceListView(viewModel: ServiceListView.ViewModel())
}
