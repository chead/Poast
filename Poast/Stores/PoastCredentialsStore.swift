//
//  PoastCredentialsStore.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation

enum PoastCredentialsStoreError: Error {
    case keychainSave
    case keychainUpdate
    case keychainDelete
    case encodeCredentials(error: Error)
    case decodeCredentials(error: Error)
}

struct PoastCredentialsStore {
    func addCredentials(identifier: String, credentials: CredentialsModel) -> PoastCredentialsStoreError? {
        do {
            let credentialsData = try JSONEncoder().encode(credentials)

            return Keychain.save(key: identifier, data: credentialsData) == 0 ? nil : .keychainSave
        } catch(let error) {
            return .encodeCredentials(error: error)
        }
    }

    func getCredentials(identifier: String) -> Result<CredentialsModel?, PoastCredentialsStoreError> {
        guard let credentialsData = Keychain.load(key: identifier) else {
            return .success(nil)
        }

        do {
            return .success(try JSONDecoder().decode(CredentialsModel.self, from: credentialsData))
        } catch(let error) {
            return .failure(.decodeCredentials(error: error))
        }
    }

    func updateCredentials(identifier: String, credentials: CredentialsModel) -> PoastCredentialsStoreError? {
        do {
            let credentialsData = try JSONEncoder().encode(credentials)

            return Keychain.update(key: identifier, data: credentialsData) == 0 ? nil : .keychainUpdate
        } catch(let error) {
            return .encodeCredentials(error: error)
        }
    }

    func deleteCredentials(identifier: String) -> PoastCredentialsStoreError? {
        return Keychain.delete(key: identifier) == 0 ? nil : .keychainDelete
    }
}
