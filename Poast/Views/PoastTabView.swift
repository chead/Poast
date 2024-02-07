//
//  PoastTabView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastTabView: View {
    @EnvironmentObject var user: PoastUser

    @State var showingComposerView: Bool = false

    var body: some View {
        TabView {
            NavigationStack {
                PoastTimelineView(timelineViewModel: PoastTimelineViewModel(algorithm: ""))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {

                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                        }

                        ToolbarItem(placement: .principal) {
                            Text("Poast")
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingComposerView = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .sheet(isPresented: $showingComposerView) {
                                EmptyView()
                            }
                        }
                    }
            }
            .tabItem { Label("Timeline", systemImage: "dot.radiowaves.up.forward") }

            Rectangle()
                .fill(.blue)
                .tabItem { Label("Feeds", systemImage: "number") }

            Rectangle()
                .fill(.red)
                .tabItem { Label("Notifications", systemImage: "bell") }

            if let handle = user.accountSession?.account.handle {
                PoastProfileView(profileViewModel: PoastProfileViewModel(handle: handle))
                    .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            }

            PoastSettingsView(accountSettingsViewModel: PoastSettingsViewModel())
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let account = PoastAccountObject(context: managedObjectContext)

    account.uuid = UUID()
    account.created = Date()
    account.handle = "@foobar.baz"
    account.host = URL(string: "https://bsky.social")!

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = account.uuid
    session.did = ""

    let user = PoastUser()

    user.accountSession = (account: account, session: session)

    return PoastTabView()
        .environmentObject(user)
}
