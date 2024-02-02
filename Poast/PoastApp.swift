//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI
import SwiftBluesky

@main
struct PoastApp: App {
    init() {
        DependencyProvider.register(BlueskyClient())
        DependencyProvider.register(PoastSessionStore())
        DependencyProvider.register(PoastSessionService())
        DependencyProvider.register(PoastAccountStore())
        DependencyProvider.register(PoastAccountService())
        DependencyProvider.register(PoastCredentialsStore())
        DependencyProvider.register(PoastCredentialsService())
    }

    var body: some Scene {
        WindowGroup {
            PoastLandingView(landingViewModel: PoastLandingViewModel())
        }
    }
}
