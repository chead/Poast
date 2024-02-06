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
    case sessionExists
    case store

    init(sessionStoreError: PoastSessionStoreError) {
        switch(sessionStoreError) {
        case .sessionExists:
            self = .sessionExists
        }
    }
}

class PoastSessionService {
    private var sessionStore = PoastSessionStore()

    func createSession(did: String, accountUUID: UUID) -> Result<PoastSessionObject, PoastSessionServiceError> {
        do {
            switch(try self.sessionStore.createSession(did: did, accountUUID: accountUUID)) {
            case .success(let session):
                return .success(session)

            case .failure(let error):
                return .failure(PoastSessionServiceError(sessionStoreError: error))
            }
        } catch {
            return .failure(.store)
        }
    }

    func getSessions(account: PoastAccountObject) -> Result<Set<PoastSessionObject>, PoastAccountServiceError> {
        do {
            return .success(try self.sessionStore.getSessions(accountUUID: account.uuid!))
        } catch(_) {
            return .failure(.store)
        }
    }

    func deleteSession(sessionDID: String) -> PoastSessionServiceError? {
        do {
            try self.sessionStore.deleteSession(did: sessionDID)

            return nil
        } catch {
            return .store
        }
    }

    func setActiveSession(session: PoastSessionObject?) {
        self.sessionStore.setActiveSessionDID(did: session?.did!)
    }

    func getActiveSession() -> Result<PoastSessionObject?, PoastSessionServiceError> {
        guard let activeSessionDID = self.sessionStore.getActiveSessionDID() else { return .success(nil) }

        do {
            return .success(try self.sessionStore.getSession(did: activeSessionDID))
        } catch {
            return .failure(.store)
        }
    }
}
