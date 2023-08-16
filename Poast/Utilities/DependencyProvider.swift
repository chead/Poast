//
//  DependencyProvider.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation
import CoreData
import SwiftBluesky

class DependencyProvider: DependencyProviding {
    private let serviceProvider = ServiceProvider()
    private let utilityProvider = UtilityProvider()
    
    static let shared = DependencyProvider()
    
    func register<Service: ServiceRepresentable>(provider: DependencyProviding) -> Service {
        return serviceProvider.register(provider: provider)
    }

    func register() -> NSManagedObjectContext {
        return utilityProvider.register()
    }
    
    func register() -> BlueskyClient {
        return utilityProvider.register()
    }
    
    func register() -> PoastCredentialsStore {
        return utilityProvider.register()
    }
    
    func register() -> PoastSessionStore {
        return utilityProvider.register()
    }
    
    func register() -> PoastAccountStore {
        return utilityProvider.register()
    }
}
