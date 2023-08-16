//
//  PoastSessionService.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

enum PoastAccountServiceError: Error {
    case store
}

class PoastAccountService: ServiceRepresentable {
    private enum UserDefaultsKeys: String {
        case activeAccount = "ActiveAccount"
    }

    private var accountStore: PoastAccountStore!

    required init(provider: DependencyProviding) {
        self.accountStore = provider.register()
    }
    
    func getAccounts() -> Result<Set<PoastAccountObject>, PoastAccountServiceError> {
        do {
            return .success(try self.accountStore.accounts())
        } catch(_) {
            return .failure(.store)
        }
    }
    
    func createAccount(host: URL, handle: String) -> Result<PoastAccountObject, PoastAccountServiceError> {
        do {
            return .success(try self.accountStore.createAccount(host: host, handle: handle))
        } catch(_) {
            return .failure(.store)
        }
    }
    
    func setActiveAccount(account: PoastAccountObject) {
        UserDefaults.standard.set(account.uuid?.uuidString, forKey: UserDefaultsKeys.activeAccount.rawValue)
    }
    
    func getActiveAccount() -> Result<PoastAccountObject?, PoastAccountServiceError> {
        if let uuidString = UserDefaults.standard.object(forKey: UserDefaultsKeys.activeAccount.rawValue) as? String,
           let uuid = UUID(uuidString: uuidString)
        {
            do {
                return .success(try self.accountStore.getAccount(uuid: uuid))
            } catch(_) {
                return .failure(.store)
            }
        } else {
            return .success(nil)
        }
    }
}
