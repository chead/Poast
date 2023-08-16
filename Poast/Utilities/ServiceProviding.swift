//
//  ServiceProviding.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

protocol ServiceProviding {
    func register<Service: ServiceRepresentable>(provider: DependencyProviding) -> Service
}
