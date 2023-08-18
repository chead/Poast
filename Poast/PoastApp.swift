//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI

@main
struct PoastApp: App {
    init() {
        DependencyProvider.register(PoastSessionService())
        DependencyProvider.register(PoastAccountService())
        DependencyProvider.register(PoastCredentialsService())
        DependencyProvider.register(PoastBlueskyService())
    }

    var body: some Scene {
        WindowGroup {
            PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
        }
    }
}
