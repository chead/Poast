//
//  PoastLandingViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import Foundation

enum PoastLandingViewModelError: Error {
    case unknown
}

class PoastLandingViewModel {
    @Dependency private var accountService: PoastAccountService
    @Dependency private var sessionService: PoastSessionService

    func getActiveSession() -> Result<PoastSessionObject?, PoastLandingViewModelError> {
        switch(self.sessionService.getActiveSession()) {
        case .success(let session):
            return .success(session)
        case .failure(_):
            return .failure(.unknown)
        }
    }

    func getAccount(session: PoastSessionObject) -> Result<PoastAccountObject?, PoastLandingViewModelError> {
        switch(self.accountService.getAccount(uuid: session.accountUUID!)) {
        case .success(let account):
            return .success(account)

        case .failure(_):
            return .failure(.unknown)
        }
    }
}
