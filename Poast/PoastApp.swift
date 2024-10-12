//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI
import SwiftData
import SwiftBluesky

class PoastUser: ObservableObject {
    @Published var session: PoastSessionModel?

    init(session: PoastSessionModel? = nil) {
        self.session = session
    }
}

@main
struct PoastApp: App {
    let user: PoastUser

    init() {
        let preferencesService = PoastPreferencesService()

        self.user = PoastUser(session: try? preferencesService.getActiveSession())

        DependencyProvider.register(BlueskyClient())
        DependencyProvider.register(PoastCredentialsService())
        DependencyProvider.register(preferencesService)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PoastAccountModel.self,
            PoastPostLikeInteractionModel.self,
            PoastPostRepostInteractionModel.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PoastLandingView(landingViewModel: PoastLandingViewModel())
                .environmentObject(user)
                .modelContainer(sharedModelContainer)
        }
    }
}
