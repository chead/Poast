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
    static func resolve() -> PoastCredentialsStore
}
