//
//  LandingView.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import SwiftUI
import SwiftData

struct LandingView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    let landingViewModel: LandingViewModel

    var body: some View {
        if user.session != nil {
            MainTabView()
        } else {
            AccountsView(accountsViewModel: AccountsViewModel(modelContext: modelContext))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AccountModel.self, configurations: config)

    LandingView(landingViewModel: LandingViewModel())
        .modelContainer(container)
}
