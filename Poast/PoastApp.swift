//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI
import SwiftBluesky

class PoastUser: ObservableObject {
    @Published var accountSession: (account: PoastAccountObject,
                                    session: PoastSessionObject)?
}

@main
struct PoastApp: App {
    let user: PoastUser

    init() {
        let sessionService = PoastSessionService()
        let accountService = PoastAccountService()

        user = PoastUser()

        switch(sessionService.getActiveSession()) {
        case .success(let session):
            if let session = session {
                switch(accountService.getAccount(uuid: session.accountUUID!)) {
                case .success(let account):
                    if let account = account {
                        user.accountSession = (account: account, session: session)
                    }

                case .failure(_):
                    break
                }
            }

        case .failure(_):
            break
        }

        DependencyProvider.register(BlueskyClient())
        DependencyProvider.register(sessionService)
        DependencyProvider.register(accountService)
        DependencyProvider.register(PoastCredentialsService())
    }

    var body: some Scene {
        WindowGroup {
            PoastLandingView(landingViewModel: PoastLandingViewModel())
                .environmentObject(user)
        }
    }
}
