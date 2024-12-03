//
//  MainTabView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    var body: some View {
        TabView {
            if let session = user.session {
                NavigationStack {
                    FollowingFeedView(followingFeedViewModel: TimelineViewModel(session: session,
                                                                             modelContext: modelContext))
                }
                .tabItem { Label("Timeline", systemImage: "dot.radiowaves.up.forward") }
            }

            Rectangle()
                .fill(.blue)
                .tabItem { Label("Feeds", systemImage: "number") }

            Rectangle()
                .fill(.red)
                .tabItem { Label("Notifications", systemImage: "bell") }

            if let session = user.session {
                NavigationStack {
                    ProfileViewDetailedView(session: session,
                                            modelContext: modelContext,
                                            handle: session.account.handle)
                }
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            }

            SettingsView(settingsViewModel: SettingsViewModel(modelContext: modelContext))
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    let account = AccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = SessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = UserModel()

    user.session = session

    return MainTabView()
        .environmentObject(user)
}
