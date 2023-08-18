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
    private var credentialsStore: PoastCredentialsStore = DependencyProvider.resolve()

    func addCredentials(account: PoastAccountObject, accessToken: String, refreshToken: String) -> Result<Bool, PoastCredentialsServiceError> {
        let credentials = PoastCredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        do {
            return .success(try self.credentialsStore.addCredentials(identifier: account.uuid!.uuidString, credentials: credentials) ? true : false)
        } catch(_) {
            return .failure(.store)
        }
    }

    func getCredentials(account: PoastAccountObject) -> Result<PoastCredentialsModel?, PoastCredentialsServiceError> {
        do {
            return .success(try self.credentialsStore.getCredentials(identifier: account.uuid!.uuidString))
        } catch(_) {
            return .failure(.store)
        }
    }

    func updateCredentials(account: PoastAccountObject, accessToken: String, refreshToken: String) -> Result<Bool, PoastCredentialsServiceError> {
        let credentials = PoastCredentialsModel(accessToken: accessToken, refreshToken: refreshToken)

        do {
            return .success(try self.credentialsStore.updateCredentials(identifier: account.uuid!.uuidString, credentials: credentials) ? true : false)
        } catch(_) {
            return .failure(.store)
        }
    }

    func deleteCredentials(account: PoastAccountObject) {
        let _ = Keychain.delete(key: account.uuid!.uuidString)
    }
}
