//
//  PoastAccountSettingsView.swift
//  Poast
//
//  Created by Christopher Head on 1/20/24.
//

import SwiftUI

struct PoastAccountSettingsView: View {
    let accountSettingsViewModel: PoastAccountSettingsViewModel

    @EnvironmentObject var session: PoastSessionObject

    @State var showingAccountsView: Bool = false

    var body: some View {
        Button("Sign Out") {
            self.accountSettingsViewModel.signOut(session: self.session)
            self.showingAccountsView = true
        }
        .navigationDestination(isPresented: self.$showingAccountsView) {
            PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    PoastAccountSettingsView(accountSettingsViewModel: PoastAccountSettingsViewModel())
}
