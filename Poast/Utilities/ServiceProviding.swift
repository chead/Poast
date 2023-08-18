//
//  ServiceProviding.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

protocol ServiceProviding {
    static func register<Dependency>(_ dependency: Dependency)
    static func resolve<Dependency>() -> Dependency
}
