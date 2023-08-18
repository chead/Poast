//
//  PoastAccountsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import Foundation

enum PoastAccountsViewModelError: Error {
    case bluesky
    case unknown
}

class PoastAccountsViewModel: ObservableObject {
    @Dependency private(set) var accountsService: PoastAccountService

    func getAccounts() -> Set<PoastAccountObject> {
        switch(accountsService.getAccounts()) {
        case .success(let accounts):
            return accounts

        case .failure(_):
            return []
        }
    }
}
