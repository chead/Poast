//
//  PoastPreferencesService.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation

class PoastPreferencesService {
    enum PreferencesKeys {
        enum Session: String {
            case activeSession = "activeSession"
        }
    }

    func setActiveSession(session: PoastSessionModel?) throws {
        let sessionData = try JSONEncoder().encode(session)

        UserDefaults.standard.setValue(sessionData, forKey: PreferencesKeys.Session.activeSession.rawValue)
    }

    func getActiveSession() throws -> PoastSessionModel? {
        if let sessionData = UserDefaults.standard.object(forKey: PreferencesKeys.Session.activeSession.rawValue) as? Data {
            return try JSONDecoder().decode(PoastSessionModel.self, from: sessionData)
        } else {
            return nil
        }
    }
}
