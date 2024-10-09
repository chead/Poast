//
//  PoastSettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI
import SwiftData

struct PoastSettingsView: View {
    @EnvironmentObject var user: PoastUser

    let settingsViewModel: PoastSettingsViewModel

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
    let container = try! ModelContainer(for: PoastAccountModel.self, configurations: config)

    PoastSettingsView(settingsViewModel: PoastSettingsViewModel(modelContext: container.mainContext))
}
