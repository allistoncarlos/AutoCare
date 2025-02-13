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
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
