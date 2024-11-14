//
//  UtilityProvider.swift
//  Poast
//
//  Created by Christopher Head on 8/2/23.
//

import Foundation
import CoreData
import SwiftBluesky

final class UtilityProvider: UtilityProviding {
    private var instances = [String: Any]()

    private static var shared = UtilityProvider()

    static func resolve() -> CredentialsStore {
        let key = "\(CredentialsStore.self)"

        guard let credentialsStore = shared.instances[key] as? CredentialsStore else {
            let credentialsStore = CredentialsStore()

            shared.instances[key] = credentialsStore
            
            return credentialsStore
        }

        return credentialsStore
    }
}
