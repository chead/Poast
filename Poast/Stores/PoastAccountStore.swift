//
//  PoastAccountStore.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation
import CoreData

enum PoastAccountStoreError: Error {
    case accountExists
}

struct PoastAccountStore {
    private let managedObjectContext = PersistenceController.shared.container.viewContext

    func accounts() throws -> Set<PoastAccountObject> {
        let accountObjectFetchRequest = PoastAccountObject.fetchRequest()
        let accountObjects = try self.managedObjectContext.fetch(accountObjectFetchRequest)

        return Set(accountObjects)
    }
    
    func getAccount(uuid: UUID) throws -> PoastAccountObject? {
        let accountObjectFetchRequest = PoastAccountObject.fetchRequest()

        accountObjectFetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)

        return try self.managedObjectContext.fetch(accountObjectFetchRequest).first
    }

    func getAccount(host: URL, handle: String) throws -> PoastAccountObject? {
        let accountObjectFetchRequest = PoastAccountObject.fetchRequest()

        accountObjectFetchRequest.predicate = NSPredicate(format: "host ==[c] %@ AND handle ==[c] %@", argumentArray: [host, handle])

        return try self.managedObjectContext.fetch(accountObjectFetchRequest).first
    }

    func createAccount(host: URL, handle: String) throws -> Result<PoastAccountObject, PoastAccountStoreError> {
        let accountObjectFetchRequest = PoastAccountObject.fetchRequest()

        accountObjectFetchRequest.predicate = NSPredicate(format: "host ==[c] %@ AND handle ==[c] %@", argumentArray: [host, handle])

        let accounts = try self.managedObjectContext.fetch(accountObjectFetchRequest)

        if(accounts.count > 0) {
            return .failure(.accountExists)
        }

        let account = PoastAccountObject(context: self.managedObjectContext)
        
        account.uuid = UUID()
        account.host = host
        account.handle = handle
        account.created = Date()

        try self.managedObjectContext.save()

        return .success(account)
    }

    func deleteAccount(uuid: UUID) throws {
        guard let account = try getAccount(uuid: uuid) else { return }

        self.managedObjectContext.delete(account)

        try self.managedObjectContext.save()
    }
}
