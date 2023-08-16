//
//  PoastCredentialsStore.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation

struct PoastCredentialsStore {
    func addCredentials(identifier: String, credentials: PoastCredentialsModel) throws -> Bool {
        let credentialsData = try JSONEncoder().encode(credentials)
        
        return Keychain.save(key: identifier, data: credentialsData) == 0 ? true : false
    }

    func getCredentials(identifier: String) throws -> PoastCredentialsModel? {
        guard let credentialsData = Keychain.load(key: identifier) else {
            return nil
        }
        
        return try JSONDecoder().decode(PoastCredentialsModel.self, from: credentialsData)
    }

    func updateCredentials(identifier: String, credentials: PoastCredentialsModel) throws -> Bool {
        let credentialsData = try JSONEncoder().encode(credentials)

        return Keychain.update(key: identifier, data: credentialsData) == 0 ? true: false
    }

    func deleteCredentials(identifier: String) {
        let _ = Keychain.delete(key: identifier)
    }
}
