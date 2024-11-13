//
//  PoastCredentialsService.swift
//  Poast
//
//  Created by Christopher Head on 8/7/23.
//

import Foundation

enum PoastCredentialsServiceError: Error {
    case credentialsStore(error: PoastCredentialsStoreError)
    case credentialsNotFound
}

class PoastCredentialsService {
    private var credentialsStore =  PoastCredentialsStore()

    func addCredentials(did: String, accessToken: String, refreshToken: String) -> PoastCredentialsServiceError? {
        let credentials = CredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        if let addCredentialsError = credentialsStore.addCredentials(identifier: did, credentials: credentials) {
            return .credentialsStore(error: addCredentialsError)
        } else {
            return nil
        }
    }

    func getCredentials(sessionDID: String) -> Result<CredentialsModel, PoastCredentialsServiceError> {
        switch(credentialsStore.getCredentials(identifier: sessionDID)) {
        case .success(.some(let credentials)):
            return .success(credentials)

        case .success(.none):
            return .failure(.credentialsNotFound)

        case .failure(let error):
            return .failure(.credentialsStore(error: error))
        }
    }

    func updateCredentials(did: String, accessToken: String, refreshToken: String) -> PoastCredentialsServiceError? {
        let credentials = CredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        if let updateCredentialsError = credentialsStore.updateCredentials(identifier: did, credentials: credentials) {
            return .credentialsStore(error: updateCredentialsError)
        } else {
            return nil
        }
    }

    func deleteCredentials(sessionDID: String) -> PoastCredentialsServiceError? {
        if let deleteCredentialsError = credentialsStore.deleteCredentials(identifier: sessionDID) {
            return .credentialsStore(error: deleteCredentialsError)
        } else {
            return nil
        }
    }
}
