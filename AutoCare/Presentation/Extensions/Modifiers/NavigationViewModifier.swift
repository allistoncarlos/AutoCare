//
//  NavigationViewModifier.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/05/24.
//

import SwiftUI

struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color?

    func body(content: Content) -> some View {
        content
            .navigationTitle(title ?? "")
            .toolbarBackground(color ?? .clear, for: .navigationBar, .tabBar)
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
    }
}
