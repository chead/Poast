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
    @Dependency private(set) var credentialsStore: PoastCredentialsStore

    func addCredentials(did: String, accessToken: String, refreshToken: String) -> Result<Bool, PoastCredentialsServiceError> {
        let credentials = PoastCredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        do {
            return .success(try self.credentialsStore.addCredentials(identifier: did, credentials: credentials) ? true : false)
        } catch(_) {
            return .failure(.store)
        }
    }

    func getCredentials(sessionDID: String) -> Result<PoastCredentialsModel?, PoastCredentialsServiceError> {
        do {
            return .success(try self.credentialsStore.getCredentials(identifier: sessionDID))
        } catch(_) {
            return .failure(.store)
        }
    }

    func deleteCredentials(sessionDID: String) -> PoastCredentialsServiceError? {
        switch(self.credentialsStore.deleteCredentials(identifier: sessionDID)) {
        case true:
            return nil
        case false:
            return .store
        }
    }
}
