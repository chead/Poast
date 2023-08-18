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

    static func resolve() -> NSManagedObjectContext {
        let key = "\(NSManagedObjectContext.self)"

        guard let managedObjectContext = shared.instances[key] as? NSManagedObjectContext else {
            let managedObjectContext = PersistenceController.shared.container.viewContext

            shared.instances[key] = managedObjectContext
            
            return managedObjectContext
        }

        return managedObjectContext
    }

    static func resolve() -> BlueskyClient {
        let key = "\(BlueskyClient.self)"

        guard let client = shared.instances[key] as? BlueskyClient else {
            let client = BlueskyClient()
            
            shared.instances[key] = client
            
            return client
        }

        return client
    }

    static func resolve() -> PoastCredentialsStore {
        let key = "\(PoastCredentialsStore.self)"

        guard let credentialsStore = shared.instances[key] as? PoastCredentialsStore else {
            let credentialsStore = PoastCredentialsStore()

            shared.instances[key] = credentialsStore
            
            return credentialsStore
        }

        return credentialsStore
    }

    static func resolve() -> PoastSessionStore {
        let key = "\(PoastSessionStore.self)"

        guard let sessionStore = shared.instances[key] as? PoastSessionStore else {
            let sessionStore = PoastSessionStore(managedObjectContext: self.resolve())
            
            shared.instances[key] = sessionStore
            
            return sessionStore
        }

        return sessionStore
    }
    
    static func resolve() -> PoastAccountStore {
        let key = "\(PoastAccountStore.self)"

        guard let accountStore = shared.instances[key] as? PoastAccountStore else {
            let accountStore = PoastAccountStore(managedObjectContext: self.resolve())
            
            shared.instances[key] = accountStore
            
            return accountStore
        }

        return accountStore
    }
}
