//
//  UtilityProviding.swift
//  Poast
//
//  Created by Christopher Head on 8/2/23.
//

import Foundation
import CoreData
import SwiftBluesky

protocol UtilityProviding {
    static func resolve() -> NSManagedObjectContext
    static func resolve() -> BlueskyClient
    static func resolve() -> PoastCredentialsStore
    static func resolve() -> PoastSessionStore
    static func resolve() -> PoastAccountStore
}
