//
//  PoastAccountsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import Foundation
import SwiftData

enum PoastAccountsViewModelError: Error {
    case preferencesService(error: Error)
    case modelContext(error: Error)
}

class PoastAccountsViewModel {
    @Dependency private var preferencesService: PoastPreferencesService
    @Dependency private var credentialsService: PoastCredentialsService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteAccount(account: PoastAccountModel) -> PoastAccountsViewModelError? {
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

    func setActiveSession(session: PoastSessionModel?) -> PoastAccountsViewModelError? {
        do {
            try self.preferencesService.setActiveSessionDid(sessionDid: session?.did)
        } catch(let error) {
            return .preferencesService(error: error)
        }

        return nil
    }
}
