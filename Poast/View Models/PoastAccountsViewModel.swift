//
//  PoastAccountsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import Foundation

enum PoastAccountsViewModelError: Error {
    case unknown
}

class PoastAccountsViewModel {
    @Dependency private var accountService: PoastAccountService
    @Dependency private var sessionService: PoastSessionService
    @Dependency private var credentialsService: PoastCredentialsService

    func getAccounts() -> Set<PoastAccountObject> {
        switch(self.accountService.getAccounts()) {
        case .success(let accounts):
            return accounts
        case .failure(_):
            return []
        }
    }

    func getSessions(account: PoastAccountObject) -> Set<PoastSessionObject> {
        switch(self.sessionService.getSessions(account: account)) {
        case .success(let sessions):
            return sessions
        case .failure(_):
            return []
        }
    }

    func deleteAccount(account: PoastAccountObject) {
        for session in self.getSessions(account: account) {
            _ = self.credentialsService.deleteCredentials(sessionDID: session.did!)
            _ = self.sessionService.deleteSession(sessionDID: session.did!)
        }

        _ = self.accountService.deleteAccount(account: account)
    }

    func setActiveSession(session: PoastSessionObject?) {
        self.sessionService.setActiveSession(session: session)
    }
}
