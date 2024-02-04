//
//  PoastTabView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastTabView: View {
    @EnvironmentObject var session: PoastSessionObject

    let account: PoastAccountObject

    var body: some View {
        TabView {
            PoastTimelineView(timelineViewModel: PoastTimelineViewModel(algorithm: ""))
                .environmentObject(session)
                .tabItem { Label("Timeline", systemImage: "dot.radiowaves.up.forward") }
            Rectangle()
                .fill(.blue)
                .tabItem { Label("Feeds", systemImage: "number") }
            Rectangle()
                .fill(.red)
                .tabItem { Label("Notifications", systemImage: "bell") }
            PoastProfileView(profileViewModel: PoastProfileViewModel(handle: account.handle!))
                .environmentObject(session)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            PoastAccountSettingsView(accountSettingsViewModel: PoastAccountSettingsViewModel())
                .environmentObject(session)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let account = PoastAccountObject(context: managedObjectContext)

    account.created = Date()
    account.handle = "Foobar"
    account.host = URL(string: "https://bsky.social")!
    account.uuid = UUID()

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = account.uuid!
    session.did = ""

    return PoastTabView(account: account)
        .environmentObject(session)
}
