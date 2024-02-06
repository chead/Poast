//
//  PoastLandingView.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import SwiftUI

struct PoastLandingView: View {
    @EnvironmentObject var user: PoastUser

    let landingViewModel: PoastLandingViewModel

    var body: some View {
        if user.accountSession != nil {
            PoastTabView()
        } else {
            PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
        }
    }
}

#Preview {
    PoastLandingView(landingViewModel: PoastLandingViewModel())
        .environmentObject(PoastUser())
}
