//
//  CurrencyTextField.swift
//  AutoCare
//  https://github.com/popei69/samples/blob/master/NumberSample/NumberSample/CurrencyTextField.swift
//  Created by Alliston Aleixo on 08/05/24.
//

import SwiftUI

struct CurrencyTextField: UIViewRepresentable {
    typealias UIViewType = CurrencyUITextField

    let numberFormatter: NumberFormatterProtocol
    @Binding var value: Int

    func makeUIView(context: Context) -> CurrencyUITextField {
        CurrencyUITextField(
            formatter: numberFormatter,
            value: value,
            onValueChanged: { newValue in
                DispatchQueue.main.async {
                    self.value = newValue
                }
            }
        )
    }

    func updateUIView(_ uiView: CurrencyUITextField, context: Context) {
        // Sincroniza o valor se necessário
        if uiView.text != formattedValue {
            uiView.text = formattedValue
        }
    }

    private var formattedValue: String {
        let decimalValue = Decimal(value) / 100.0
        return numberFormatter.string(for: decimalValue) ?? ""
    }
}
