//
//  PoastSessionService.swift
//  Poast
//
//  Created by Christopher Head on 8/5/23.
//

import Foundation
import CoreData
import SwiftBluesky

enum PoastSessionServiceError: Error {
    case store
}

class PoastSessionService: ServiceRepresentable {
    private var sessionStore: PoastSessionStore!
    
    required init(provider: DependencyProviding) {
        self.sessionStore = provider.register()
    }
    
    func createSession(account: PoastAccountObject) -> Result<PoastSessionObject, PoastSessionServiceError> {
        if let oldSession = account.session {
            do {
                try sessionStore.deleteSession(session: oldSession)
            } catch {
                return .failure(.store)
            }
        }
        
        do {
            return .success(try self.sessionStore.createSession(account: account))
        } catch {
            return .failure(.store)
        }
    }
}
