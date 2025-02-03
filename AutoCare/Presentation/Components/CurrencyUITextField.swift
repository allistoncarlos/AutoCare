//
//  CurrencyUITextField.swift
//  AutoCare
//  https://github.com/popei69/samples/blob/master/NumberSample/NumberSample/CurrencyUITextField.swift
//  Created by Alliston Aleixo on 08/05/24.
//

import UIKit

class CurrencyUITextField: UITextField {
    private let formatter: NumberFormatterProtocol
    private var onValueChanged: (Int) -> Void
    private var currentValue: Int = 0

    init(formatter: NumberFormatterProtocol, value: Int, onValueChanged: @escaping (Int) -> Void) {
        self.formatter = formatter
        self.onValueChanged = onValueChanged
        super.init(frame: .zero)
        self.currentValue = value
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(resetSelection), for: .allTouchEvents)
        keyboardType = .numberPad
        textAlignment = .right
        sendActions(for: .editingChanged)
    }

    override func deleteBackward() {
        text = textValue.digits.dropLast().string
        sendActions(for: .editingChanged)
    }

    private func setupViews() {
        setInitialValue()
    }

    private func setInitialValue() {
        if currentValue > 0 {
            let val = Double(currentValue)
            let decimalValue = Decimal(val / 100.0)
            text = currency(from: decimalValue)
        }
    }

    @objc private func editingChanged() {
        text = currency(from: decimal)
        resetSelection()
        updateValue()
    }

    @objc private func resetSelection() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }

    private func updateValue() {
        currentValue = intValue
        onValueChanged(currentValue)
    }

    private var textValue: String {
        return text ?? ""
    }

    private var decimal: Decimal {
        return textValue.decimal / pow(10, formatter.maximumFractionDigits)
    }

    private var intValue: Int {
        return NSDecimalNumber(decimal: decimal * 100).intValue
    }

    private func currency(from decimal: Decimal) -> String {
        return formatter.string(for: decimal) ?? ""
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter(\.isWholeNumber) }
}

extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}
