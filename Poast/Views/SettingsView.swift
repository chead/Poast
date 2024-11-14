//
//  SettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var user: UserModel

    let settingsViewModel: SettingsViewModel

    var body: some View {
        VStack {
            Spacer()

            Button("Switch Account") {
                user.session = nil
            }

            Spacer()

            Button("Sign Out") {
                if let session = user.session {
                    settingsViewModel.signOut(session: session)

                    user.session = nil
                }
            }

            Spacer()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AccountModel.self, configurations: config)

    SettingsView(settingsViewModel: SettingsViewModel(modelContext: container.mainContext))
}
