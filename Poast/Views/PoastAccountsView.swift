//
//  PoastAccountsView.swift
//  Poast
//
//  Created by Christopher Head on 8/1/23.
//

import SwiftUI

struct PoastAccountsView: View {
    @StateObject var accountsViewModel: PoastAccountsViewModel

    @State var accounts: [PoastAccountObject] = []

    @State private var selectedAccount: PoastAccountObject?
    @State private var showingSignInView: Bool = false

    var body: some View {
        NavigationStack {
            List(self.accounts, id: \.self, selection: $selectedAccount) { account in
                NavigationLink(account.handle!, value: account)
//                NavigationLink(account.handle!) {
//                    PoastProfileView(profileViewModel: PoastProfileViewModel(provider: DependencyProvider.shared, session: account.session!, handle: account.handle!))
//                }
            }
            .navigationDestination(for: PoastAccountObject.self, destination: { account in

            })
            .navigationTitle("Accounts")
            .toolbar {
                Button {
                    showingSignInView = true
                } label: {
                    Image(systemName: "plus")
                }
                .navigationDestination(isPresented: $showingSignInView) {
                    PoastSignInView(signInViewModel: PoastSignInViewModel(provider: DependencyProvider.shared), accounts: self.$accounts)
                }
            }
        }
        .onAppear() {
            self.accounts = self.accountsViewModel.getAccounts().sorted { $0.handle! < $1.handle! }
        }
    }
}

struct PoastAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PoastAccountsView(accountsViewModel: PoastAccountsViewModel(provider: nil))
    }
}
