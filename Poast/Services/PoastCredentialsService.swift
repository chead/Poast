//
//  PoastCredentialsService.swift
//  Poast
//
//  Created by Christopher Head on 8/7/23.
//

import Foundation

enum PoastCredentialsServiceError: Error {
    case store
}

class PoastCredentialsService {
    private var credentialsStore =  PoastCredentialsStore()

    func addCredentials(did: String, accessToken: String, refreshToken: String) -> PoastCredentialsServiceError? {
        let credentials = PoastCredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        do {
            return try credentialsStore.addCredentials(identifier: did, credentials: credentials) ? nil : .store
        } catch(_) {
            return .store
        }
    }

    func getCredentials(sessionDID: String) -> Result<PoastCredentialsModel?, PoastCredentialsServiceError> {
        do {
            return .success(try credentialsStore.getCredentials(identifier: sessionDID))
        } catch(_) {
            return .failure(.store)
        }
    }

    func updateCredentials(did: String, accessToken: String, refreshToken: String) -> PoastCredentialsServiceError? {
        let credentials = PoastCredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        do {
            return try credentialsStore.updateCredentials(identifier: did, credentials: credentials) ? nil : .store
        } catch(_) {
            return .store
        }
    }

    func deleteCredentials(sessionDID: String) -> PoastCredentialsServiceError? {
        return credentialsStore.deleteCredentials(identifier: sessionDID) ? nil : .store
    }
}
