//
//  PoastSettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastSettingsView: View {
    @EnvironmentObject var user: PoastUser

    let settingsViewModel: PoastSettingsViewModel

    var body: some View {
        VStack {
            Spacer()

            Button("Switch Account") {
                user.accountSession = nil
            }

            Spacer()

            Button("Sign Out") {
                guard let session = user.accountSession?.session else {
                    return
                }

                settingsViewModel.signOut(session: session)

                user.accountSession = nil
            }

            Spacer()
        }
    }
}

#Preview {
    PoastSettingsView(settingsViewModel: PoastSettingsViewModel())
}
