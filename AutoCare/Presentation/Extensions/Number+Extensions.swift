//
//  Number+Extensions.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 08/04/24.
//

import Foundation
import RealmSwift

extension Double {
    func toCurrencyString() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        return numberFormatter.string(from: NSNumber(value: self))
    }
}

extension Int {
    func toLeadingZerosString(decimalPlaces: Int) -> String {
        return String(format: "%0\(decimalPlaces)d", self)
    }
}

extension Decimal {
    public func roundedDecimal128(places: Int16) -> Decimal128 {
        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .bankers,
            scale: places,
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )

        let decimalNumber = NSDecimalNumber(decimal: self)
        let roundedNumber = decimalNumber.rounding(accordingToBehavior: roundingBehavior)
        
        let roundedDecimal = roundedNumber as Decimal
        return Decimal128(value: roundedDecimal)
    }
}

extension Decimal128 {
    func toLeadingZerosString(decimalPlaces: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = decimalPlaces

        return numberFormatter.string(from: NSDecimalNumber(decimal: self.decimalValue))
    }

    func toCurrencyString(currencyCode: String = "BRL", identifier: String = "pt_BR") -> String? {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: identifier)
        formatter.numberStyle = .currency

        return formatter.string(for: self.decimalValue)
    }
}
