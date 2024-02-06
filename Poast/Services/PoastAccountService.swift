//
//  PoastSessionService.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

enum PoastAccountServiceError: Error {
    case accountExists
    case store

    init(accountStoreError: PoastAccountStoreError) {
        switch(accountStoreError) {
        case .accountExists:
            self = .accountExists
        }
    }
}

class PoastAccountService {
    private var accountStore = PoastAccountStore()

    func getOrCreateAccount(host: URL, handle: String) -> Result<PoastAccountObject, PoastAccountServiceError> {
        do {
            if let account = try self.accountStore.getAccount(host: host, handle: handle) {
                return .success(account)
            }

            switch(try self.accountStore.createAccount(host: host, handle: handle)) {
            case .success(let account):
                return .success(account)

            case .failure(let error):
                return .failure(PoastAccountServiceError(accountStoreError: error))
            }

        } catch(_) {
            return .failure(.store)
        }
    }

    func getAccounts() -> Result<Set<PoastAccountObject>, PoastAccountServiceError> {
        do {
            return .success(try self.accountStore.accounts())
        } catch(_) {
            return .failure(.store)
        }
    }

    func getAccount(uuid: UUID) -> Result<PoastAccountObject?, PoastAccountServiceError> {
        do {
            return .success(try self.accountStore.getAccount(uuid: uuid))
        } catch {
            return .failure(.store)
        }
    }

    func deleteAccount(account: PoastAccountObject) -> PoastAccountServiceError? {
        do {
            try self.accountStore.deleteAccount(uuid: account.uuid!)

            return nil
        } catch {
            return .store
        }
    }
}
