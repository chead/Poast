//
//  PoastLandingViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import Foundation

enum PoastLandingViewModelError: Error {
    case preferencesService
}

class PoastLandingViewModel {
    @Dependency private var preferencesService: PoastPreferencesService

    func getActiveSession() -> PoastSessionModel? {
        return try? self.preferencesService.getActiveSession()
    }
}
