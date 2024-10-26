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
    let user: PoastUser

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PoastAccountModel.self,
            PoastPostLikeInteractionModel.self,
            PoastPostRepostInteractionModel.self,
            PoastThreadMuteInteractionModel.self
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
        var activeSession: PoastSessionModel? = nil

        if let activeSessionDid = try? preferencesService.getActiveSessionDid() {
            let sessionsFetchDescriptor = FetchDescriptor<PoastSessionModel>(predicate: #Predicate { session in
                session.did == activeSessionDid
            })

            activeSession = try? sharedModelContainer.mainContext.fetch(sessionsFetchDescriptor).first
        }

        self.user = PoastUser(session: activeSession)

        DependencyProvider.register(BlueskyClient())
        DependencyProvider.register(PoastCredentialsService())
        DependencyProvider.register(preferencesService)
    }

    var body: some Scene {
        WindowGroup {
            PoastLandingView(landingViewModel: PoastLandingViewModel())
                .environmentObject(user)
                .modelContainer(sharedModelContainer)
        }
    }
}
