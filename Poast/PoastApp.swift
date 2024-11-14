//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI
import SwiftData
import SwiftBluesky

@main
struct PoastApp: App {
    let user: UserModel

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AccountModel.self,
            LikeInteractionModel.self,
            RepostInteractionModel.self,
            MuteInteractionModel.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let preferencesService = PoastPreferencesService()
        var activeSession: SessionModel? = nil

        if let activeSessionDid = preferencesService.getActiveSessionDid() {
            let sessionsFetchDescriptor = FetchDescriptor<SessionModel>(predicate: #Predicate { session in
                session.did == activeSessionDid
            })

            activeSession = try? sharedModelContainer.mainContext.fetch(sessionsFetchDescriptor).first
        }

        self.user = UserModel(session: activeSession)

        DependencyProvider.register(PoastCredentialsService())
        DependencyProvider.register(preferencesService)
    }

    var body: some Scene {
        WindowGroup {
            PoastLandingView(landingViewModel: LandingViewModel())
                .environmentObject(user)
                .modelContainer(sharedModelContainer)
        }
    }
}
