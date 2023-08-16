//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI

@main
struct PoastApp: App {
    let dependencyProvider = DependencyProvider.shared

    var body: some Scene {
        WindowGroup {
            PoastAccountsView(accountsViewModel: PoastAccountsViewModel(provider: dependencyProvider))
        }
    }
}
