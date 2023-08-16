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
    func register() -> NSManagedObjectContext
    func register() -> BlueskyClient
    func register() -> PoastCredentialsStore
    func register() -> PoastSessionStore
    func register() -> PoastAccountStore
}
