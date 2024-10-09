//
//  PoastAccountsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import Foundation
import SwiftData

enum PoastAccountsViewModelError: Error {
    case preferences
    case database
    case unknown
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
        } catch {
            return .database
        }

        return nil
    }

    func setActiveSession(session: PoastSessionModel?) -> PoastAccountsViewModelError? {
        do {
            try self.preferencesService.setActiveSession(session: session)
        } catch {
            return .preferences
        }

        return nil
    }
}
