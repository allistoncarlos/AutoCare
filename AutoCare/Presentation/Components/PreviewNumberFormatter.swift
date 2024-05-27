//
//  PreviewNumberFormatter.swift
//  AutoCare
//  https://github.com/popei69/samples/blob/master/NumberSample/NumberSample/ContentView.swift
//  Created by Alliston Aleixo on 08/05/24.
//

import SwiftUI
import Combine

protocol NumberFormatterProtocol: AnyObject {
    func string(from number: NSNumber) -> String?
    func string(for obj: Any?) -> String?
    var numberStyle: NumberFormatter.Style { get set }
    var maximumFractionDigits: Int { get set }
}

extension NumberFormatter: NumberFormatterProtocol { }

class PreviewNumberFormatter: NumberFormatterProtocol {
    
    let numberFormatter: NumberFormatter
    
    init(locale: Locale) {
        numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
    }
    
    var numberStyle: NumberFormatter.Style {
        get {
            return numberFormatter.numberStyle
        }
        set {
            numberFormatter.numberStyle = newValue
        }
    }
    
    var maximumFractionDigits: Int {
        get {
            return numberFormatter.maximumFractionDigits
        }
        set {
            numberFormatter.maximumFractionDigits = newValue
        }
    }
    
    func string(from number: NSNumber) -> String? {
        return numberFormatter.string(from: number)
    }
    
    func string(for obj: Any?) -> String? {
        numberFormatter.string(for: obj)
    }
}
