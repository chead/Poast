//
//  PoastAccountSettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastAccountSettingsView: View {
    @EnvironmentObject var user: PoastUser

    let accountSettingsViewModel: PoastAccountSettingsViewModel

    var body: some View {
        Button("Sign Out") {
            guard let session = user.accountSession?.session else {
                return
            }

            accountSettingsViewModel.signOut(session: session)

            user.accountSession = nil
        }
    }
}

#Preview {
    PoastAccountSettingsView(accountSettingsViewModel: PoastAccountSettingsViewModel())
}
