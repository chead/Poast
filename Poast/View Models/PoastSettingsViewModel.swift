//
//  PoastSettingsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import Foundation
import SwiftData

class PoastSettingsViewModel {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var preferencesService: PoastPreferencesService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func signOut(session: PoastSessionModel) {
        _ = self.credentialsService.deleteCredentials(sessionDID: session.did)

        try? preferencesService.setActiveSession(session: nil)

        modelContext.delete(session)

        try? modelContext.save()
    }
}

