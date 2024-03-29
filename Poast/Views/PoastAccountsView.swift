//
//  PoastAccountsView.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import SwiftUI

struct PoastAccountsView: View {
    @EnvironmentObject var user: PoastUser

    let accountsViewModel: PoastAccountsViewModel

    @State var selectedAccount: PoastAccountObject?
    @State var accounts: [PoastAccountObject] = []
    @State private var showingSignInView: Bool = false

    var body: some View {
        NavigationStack() {
            List {
                ForEach(self.accounts) { account in
                    VStack {
                        Button(action: {
                            let session = self.accountsViewModel.getSessions(account: account).first

                            if let session {
                                self.accountsViewModel.setActiveSession(session: session)

                                user.accountSession = (account: account, session: session)
                            } else {
                                selectedAccount = account
                            }
                        }) {
                            Text("\(account.handle!) @ \(account.host!.host()!)")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { accountsViewModel.deleteAccount(account: self.accounts[$0]) }

                    self.accounts.remove(atOffsets: indexSet)
                }
            }
            .navigationDestination(item: $selectedAccount, destination: { account in
                PoastSignInView(host: account.host!.absoluteString, handle: account.handle!, signInViewModel: PoastSignInViewModel())
            })
            .navigationTitle("Accounts")
            .toolbar {
                EditButton()
                Button {
                    showingSignInView = true
                } label: {
                    Image(systemName: "plus")
                }
                .navigationDestination(isPresented: $showingSignInView) {
                   PoastSignInView(signInViewModel: PoastSignInViewModel())
                }
            }
            .onAppear {
                self.accounts = accountsViewModel.getAccounts().sorted { $0.handle! > $1.handle! }
            }
        }
    }
}

#Preview {
    PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
}
