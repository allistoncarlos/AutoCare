//
//  Syncable.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/03/25.
//


import Foundation

@objc public protocol Syncable: AnyObject {
    var synced: Bool { get set }
}
