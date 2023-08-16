//
//  PoastAccountStore.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation
import CoreData

struct PoastAccountStore {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

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
    
    func createAccount(host: URL, handle: String) throws -> PoastAccountObject {
        let account = PoastAccountObject(context: self.managedObjectContext)
        
        account.uuid = UUID()
        account.host = host
        account.handle = handle

        try self.managedObjectContext.save()

        return account
    }

    func deleteAccount(account: PoastAccountObject) throws {
        let accountObjectFetchRequest = PoastAccountObject.fetchRequest()
        
        accountObjectFetchRequest.predicate = NSPredicate(format: "uuid = %@", account.uuid! as CVarArg)
        
        let accountObjects = try self.managedObjectContext.fetch(accountObjectFetchRequest)

        accountObjects.forEach { self.managedObjectContext.delete($0) }

        try self.managedObjectContext.save()
    }
}
