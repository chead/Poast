//
//  PoastSettingsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import Foundation

class PoastSettingsViewModel {
    @Dependency private var sessionService: PoastSessionService
    @Dependency private var credentialsService: PoastCredentialsService

    func signOut(session: PoastSessionObject) {
        _ = self.credentialsService.deleteCredentials(sessionDID: session.did!)
        
        self.sessionService.setActiveSession(session: nil)
        
        _ = self.sessionService.deleteSession(sessionDID: session.did!)
    }
}
