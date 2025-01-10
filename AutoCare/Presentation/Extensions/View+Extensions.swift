//
//  View+Extensions.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/05/24.
//

import SwiftUI

extension View {
    func navigationView(title: String?, color: Color? = nil) -> some View {
        modifier(NavigationViewModifier(title: title, color: color))
    }
}
