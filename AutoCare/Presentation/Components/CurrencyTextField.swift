//
//  CurrencyTextField.swift
//  AutoCare
//  https://github.com/popei69/samples/blob/master/NumberSample/NumberSample/CurrencyTextField.swift
//  Created by Alliston Aleixo on 08/05/24.
//

import Foundation
import SwiftUI

struct CurrencyTextField: UIViewRepresentable {

    typealias UIViewType = CurrencyUITextField

    let numberFormatter: NumberFormatterProtocol
    let currencyField: CurrencyUITextField

    init(numberFormatter: NumberFormatterProtocol, value: Binding<Int>) {
        self.numberFormatter = numberFormatter
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
    }

    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }

    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}
