//
//  Config.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import Foundation

internal enum Config {
    static let apiPath: String = (Bundle.main.infoDictionary!["API_PATH"] as? String)!
}
