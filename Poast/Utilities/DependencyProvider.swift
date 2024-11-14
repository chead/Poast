//
//  DependencyProvider.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation
import CoreData
import SwiftBluesky

@propertyWrapper
struct Dependency<T> {
    var wrappedValue: T

    init() {
        self.wrappedValue = DependencyProvider.resolve()
    }
}

class DependencyProvider: DependencyProviding {
    static let shared = DependencyProvider()
    
    static func register<Dependency>(_ dependency: Dependency) {
        ServiceProvider.register(dependency)
    }

    static func resolve<Dependency>() -> Dependency {
        ServiceProvider.resolve()
    }
    
    static func resolve() -> CredentialsStore {
        return UtilityProvider.resolve()
    }
}
