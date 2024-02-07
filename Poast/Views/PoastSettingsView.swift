//
//  PoastSettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastSettingsView: View {
    @EnvironmentObject var user: PoastUser

    let accountSettingsViewModel: PoastSettingsViewModel

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

                accountSettingsViewModel.signOut(session: session)

                user.accountSession = nil
            }

            Spacer()
        }
    }
}

#Preview {
    PoastSettingsView(accountSettingsViewModel: PoastSettingsViewModel())
}
