//
//  PoastLandingView.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import SwiftUI
import SwiftData

struct PoastLandingView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    let landingViewModel: PoastLandingViewModel

    var body: some View {
        if user.session != nil {
            PoastTabView()
        } else {
            PoastAccountsView(accountsViewModel: PoastAccountsViewModel(modelContext: modelContext))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AccountModel.self, configurations: config)

    PoastLandingView(landingViewModel: PoastLandingViewModel())
        .modelContainer(container)
}
