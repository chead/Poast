//
//  PreferencesService.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftData

class PreferencesService {
    private enum PreferencesKeys {
        enum Session: String {
            case activeSessionDid = "activeSessionDid"
        }
    }

    func setActiveSessionDid(sessionDid: String?) {
        UserDefaults.standard.setValue(sessionDid, forKey: PreferencesKeys.Session.activeSessionDid.rawValue)
    }

    func getActiveSessionDid() -> String? {
        UserDefaults.standard.object(forKey: PreferencesKeys.Session.activeSessionDid.rawValue) as? String
    }
}
