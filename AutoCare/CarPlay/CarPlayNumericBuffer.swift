//
//  CarPlayNumericBuffer.swift
//  AutoCare
//

import Foundation

#if canImport(CarPlay)
/// Buffer de digitação no CarPlay (odômetro inteiro ou valor em centavos).
struct CarPlayNumericBuffer {
    enum Kind {
        case integer
        case currency
    }

    private(set) var digits: String
    let kind: Kind
    let maximumDigits: Int
    private var replacesOnNextDigit: Bool

    init(kind: Kind, seed: String = "", maximumDigits: Int = 8) {
        self.kind = kind
        self.maximumDigits = maximumDigits
        self.digits = Self.sanitized(seed)
        self.replacesOnNextDigit = !seed.isEmpty
    }

    static func integer(value: Int) -> CarPlayNumericBuffer {
        CarPlayNumericBuffer(kind: .integer, seed: value > 0 ? "\(value)" : "")
    }

    static func currency(value: Decimal) -> CarPlayNumericBuffer {
        let cents = NSDecimalNumber(decimal: value * 100).intValue
        let seed = cents > 0 ? "\(cents)" : ""
        return CarPlayNumericBuffer(kind: .currency, seed: seed, maximumDigits: 8)
    }

    mutating func append(digit: Int) {
        guard (0...9).contains(digit) else { return }

        if replacesOnNextDigit {
            digits = "\(digit)"
            replacesOnNextDigit = false
            return
        }

        guard digits.count < maximumDigits else { return }

        if digits == "0" {
            digits = "\(digit)"
        } else {
            digits.append("\(digit)")
        }
    }

    mutating func deleteLast() {
        replacesOnNextDigit = false
        guard !digits.isEmpty else { return }
        digits.removeLast()
    }

    mutating func clear() {
        digits = ""
        replacesOnNextDigit = false
    }

    var isEmpty: Bool { digits.isEmpty }

    var displayText: String {
        switch kind {
        case .integer:
            return integerValue.map { "\($0)" } ?? "—"
        case .currency:
            return decimalValue?.toCurrencyString() ?? "R$ 0,00"
        }
    }

    var integerValue: Int? {
        guard kind == .integer, let value = Int(digits) else { return nil }
        return value
    }

    var decimalValue: Decimal? {
        guard kind == .currency else { return nil }
        let cents = Int(digits) ?? 0
        return (Decimal(cents) / 100).roundedDecimal(places: 2)
    }

    private static func sanitized(_ seed: String) -> String {
        seed.filter(\.isNumber)
    }
}
#endif
