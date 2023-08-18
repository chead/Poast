//
//  ServiceProvider.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

class ServiceProvider: ServiceProviding {
    private var instances = [String: AnyObject]()

    private static var shared = ServiceProvider()

    static func register<Dependency>(_ dependency: Dependency) {
        shared.register(dependency)
    }

    static func resolve<Dependency>() -> Dependency {
        shared.resolve()
    }

    private func register<Dependency>(_ dependency: Dependency) {
        let key: String = "\(Dependency.self)"
        
        instances[key] = dependency as AnyObject
    }

    private func resolve<Dependency>() -> Dependency {
        let key = String(describing: Dependency.self)
        let dependency = instances[key] as? Dependency

        return dependency!
    }
}
