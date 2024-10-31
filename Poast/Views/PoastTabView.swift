//
//  PoastTabView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastTabView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: PoastUser

    var body: some View {
        TabView {
            if let session = user.session {
                NavigationStack {
                    PoastFollowingFeedView(followingFeedViewModel: PoastFollowingFeedViewModel(session: session,
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
                    PoastProfileView(profileViewModel: PoastProfileViewModel(session: session,
                                                                             handle: session.account.handle),
                                     authorFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                                   modelContext: modelContext,
                                                                                   actor: session.account.handle),
                                     likesFeedViewModel: PoastLikesFeedViewModel(session: session,
                                                                                 modelContext: modelContext,
                                                                                 actor: session.account.handle))
                }
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            }

            PoastSettingsView(settingsViewModel: PoastSettingsViewModel(modelContext: modelContext))
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    let account = PoastAccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = PoastSessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = PoastUser()

    user.session = session

    return PoastTabView()
        .environmentObject(user)
}
