//
//  PoastPreferencesStore.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation

enum PoastPreferencesStoreError: Error {
    case sessionExists
}

struct PoastPreferencesStore {
    private enum DefaultsKeys: String {
        case activeSessionDID = "ActiveSessionDID"
    }


}
