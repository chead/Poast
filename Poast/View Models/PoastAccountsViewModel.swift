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
    private let accountsService: PoastAccountService?

    required init(provider: DependencyProviding? = nil) {
        if let provider = provider {
            self.accountsService = provider.register(provider: provider)
        } else {
            self.accountsService = nil
        }
    }

    func getAccounts() -> Set<PoastAccountObject> {
        guard let accountsService = self.accountsService else {
            return []
        }

        switch(accountsService.getAccounts()) {
        case .success(let accounts):
            return accounts

        case .failure(_):
            return []
        }
    }
}
