//
//  AccountsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import Foundation
import SwiftData

enum AccountsViewModelError: Error {
    case preferencesService(error: Error)
    case modelContext(error: Error)
}

class AccountsViewModel {
    @Dependency private var preferencesService: PreferencesService
    @Dependency private var credentialsService: CredentialsService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteAccount(account: AccountModel) -> AccountsViewModelError? {
        if let session = account.session {
            _ = self.credentialsService.deleteCredentials(sessionDID: session.did)
        }

        modelContext.delete(account)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        return nil
    }

    func setActiveSession(session: SessionModel?) {
        self.preferencesService.setActiveSessionDid(sessionDid: session?.did)
    }
}
