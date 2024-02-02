//
//  PoastSessionStore.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation
import CoreData

enum PoastSessionStoreError: Error {
    case sessionExists
}

struct PoastSessionStore {
    private enum DefaultsKeys: String {
        case activeSessionDID = "ActiveSessionDID"
    }

    private let managedObjectContext = PersistenceController.shared.container.viewContext
    private let defaults = UserDefaults.standard

    func createSession(did: String, accountUUID: UUID) throws -> Result<PoastSessionObject, PoastSessionStoreError> {
        let sessionObjectFetchRequest = PoastSessionObject.fetchRequest()

        sessionObjectFetchRequest.predicate = NSPredicate(format: "did == %@ AND accountUUID == %@", argumentArray: [did, accountUUID])

        let sessions = try self.managedObjectContext.fetch(sessionObjectFetchRequest)

        if(sessions.count > 0) {
            return .failure(.sessionExists)
        }

        let session = PoastSessionObject(context: self.managedObjectContext)

        session.created = Date()
        session.did = did
        session.accountUUID = accountUUID

        try self.managedObjectContext.save()

        return .success(session)
    }

    func getSession(did: String) throws -> PoastSessionObject? {
        let sessionObjectFetchRequest = PoastSessionObject.fetchRequest()

        sessionObjectFetchRequest.predicate = NSPredicate(format: "did == %@", argumentArray: [did])

        let sessions = try self.managedObjectContext.fetch(sessionObjectFetchRequest)

        return sessions.first
    }

    func getSessions(accountUUID: UUID) throws -> Set<PoastSessionObject> {
        let sessionObjectFetchRequest = PoastSessionObject.fetchRequest()

        sessionObjectFetchRequest.predicate = NSPredicate(format: "accountUUID == %@", argumentArray: [accountUUID])

        let sessions = try self.managedObjectContext.fetch(sessionObjectFetchRequest)

        return Set(sessions)
    }

    func deleteSession(did: String) throws {
        guard let session = try getSession(did: did) else { return }

        self.managedObjectContext.delete(session)

        try self.managedObjectContext.save()
    }

    func setActiveSessionDID(did: String?) {
        UserDefaults.standard.setValue(did, forKey: DefaultsKeys.activeSessionDID.rawValue)
    }

    func getActiveSessionDID() -> String? {
        return UserDefaults.standard.object(forKey: DefaultsKeys.activeSessionDID.rawValue) as? String
    }
}
