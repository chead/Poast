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

    func register() -> NSManagedObjectContext {
        let key = "\(NSManagedObjectContext.self)"

        guard let managedObjectContext = instances[key] as? NSManagedObjectContext else {
            let managedObjectContext = PersistenceController.shared.container.viewContext

            instances[key] = managedObjectContext
            
            return managedObjectContext
        }

        return managedObjectContext
    }

    func register() -> BlueskyClient {
        let key = "\(BlueskyClient.self)"

        guard let client = instances[key] as? BlueskyClient else {
            let client = BlueskyClient()
            
            instances[key] = client
            
            return client
        }

        return client
    }

    func register() -> PoastCredentialsStore {
        let key = "\(PoastCredentialsStore.self)"

        guard let credentialsStore = instances[key] as? PoastCredentialsStore else {
            let credentialsStore = PoastCredentialsStore()

            instances[key] = credentialsStore
            
            return credentialsStore
        }

        return credentialsStore
    }

    func register() -> PoastSessionStore {
        let key = "\(PoastSessionStore.self)"

        guard let sessionStore = instances[key] as? PoastSessionStore else {
            let sessionStore = PoastSessionStore(managedObjectContext: self.register())
            
            instances[key] = sessionStore
            
            return sessionStore
        }

        return sessionStore
    }
    
    func register() -> PoastAccountStore {
        let key = "\(PoastAccountStore.self)"

        guard let accountStore = instances[key] as? PoastAccountStore else {
            let accountStore = PoastAccountStore(managedObjectContext: self.register())
            
            instances[key] = accountStore
            
            return accountStore
        }

        return accountStore
    }
}
