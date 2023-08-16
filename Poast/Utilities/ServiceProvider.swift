//
//  ServiceProvider.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

class ServiceProvider: ServiceProviding {
    private var instances = [String: ServiceRepresentable]()

    func register<Service: ServiceRepresentable>(provider: DependencyProviding) -> Service {
        let key: String = "\(Service.self)"
        
        guard let service = instances[key] as? Service else {
            return instance(key: key, provider: provider)
        }
        
        return service
    }

    private func instance<Service: ServiceRepresentable>(key: String, provider: DependencyProviding) -> Service {
        let service = Service(provider: provider)
        
        instances[key] = service
        
        return service
    }
}
