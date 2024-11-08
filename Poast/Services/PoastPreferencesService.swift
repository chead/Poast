//
//  PoastPreferencesService.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftData

class PoastPreferencesService {
    private enum PreferencesKeys {
        enum Session: String {
            case activeSessionDid = "activeSessionDid"
        }
    }

    func setActiveSessionDid(sessionDid: String?) throws {
        UserDefaults.standard.setValue(sessionDid, forKey: PreferencesKeys.Session.activeSessionDid.rawValue)
    }

    func getActiveSessionDid() throws -> String? {
        UserDefaults.standard.object(forKey: PreferencesKeys.Session.activeSessionDid.rawValue) as? String
    }
}
