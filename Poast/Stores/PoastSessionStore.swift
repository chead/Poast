//
//  PoastSessionStore.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation
import CoreData

enum PoastSessionStoreError: Error {
    case sessionNotFound
}

struct PoastSessionStore {
    private let managedObjectContext: NSManagedObjectContext
    private let accountStore: PoastAccountStore
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.accountStore = PoastAccountStore(managedObjectContext: managedObjectContext)
    }

    func sessions() throws -> Set<PoastSessionObject> {
        let sessionObjectFetchRequest = PoastSessionObject.fetchRequest()
        let sessionObjects = try self.managedObjectContext.fetch(sessionObjectFetchRequest)

        return Set(sessionObjects)
    }

    func createSession(account: PoastAccountObject) throws -> PoastSessionObject {
        let session = PoastSessionObject(context: self.managedObjectContext)

        session.created = Date()
        session.uuid = UUID()
        session.account = account

        try self.managedObjectContext.save()

        return session
    }

    func deleteSession(session: PoastSessionObject) throws {
        let sessionObjectFetchRequest = PoastSessionObject.fetchRequest()

        sessionObjectFetchRequest.predicate = NSPredicate(format: "uuid = %@", session.uuid! as CVarArg)

        let sessionObjects = try self.managedObjectContext.fetch(sessionObjectFetchRequest)

        sessionObjects.forEach { self.managedObjectContext.delete($0) }

        try self.managedObjectContext.save()
    }
}
