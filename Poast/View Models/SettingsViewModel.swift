//
//  SettingsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import Foundation
import SwiftData

class SettingsViewModel {
    @Dependency private var credentialsService: CredentialsService
    @Dependency private var preferencesService: PreferencesService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func signOut(session: SessionModel) {
        _ = self.credentialsService.deleteCredentials(sessionDID: session.did)

        preferencesService.setActiveSessionDid(sessionDid: nil)

        modelContext.delete(session)

        try? modelContext.save()
    }
}

