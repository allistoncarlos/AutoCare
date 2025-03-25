//
//  Config.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import Foundation

internal enum Config {
    static let appId: String = (Bundle.main.infoDictionary!["APP_ID"] as? String)!
    static let apiPath: String = (Bundle.main.infoDictionary!["API_PATH"] as? String)!
}
