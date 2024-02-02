//
//  PoastAccountsView.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import SwiftUI

struct PoastAccountsView: View {
    struct AccountSession: Hashable {
        var account: PoastAccountObject
        var session: PoastSessionObject?
    }

    let accountsViewModel: PoastAccountsViewModel

    @State var selectedAccountSession: AccountSession? = nil
    @State var accounts: [PoastAccountObject] = []
    @State private var showingSignInView: Bool = false

    var body: some View {
        NavigationStack() {
            List {
                ForEach(self.accounts) { account in
                    VStack {
                        Button(action: {
                            let session = self.accountsViewModel.getSessions(account: account).first

                            if session != nil {
                                self.accountsViewModel.setActiveSession(session: session)
                            }

                            self.selectedAccountSession = AccountSession(account: account, session: session)
                        }) {
                            Text("\(account.handle!) @ \(account.host!.host()!)")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { self.accountsViewModel.deleteAccount(account: self.accounts[$0]) }

                    self.accounts.remove(atOffsets: indexSet)
                }
            }
            .navigationDestination(item: self.$selectedAccountSession, destination: { accountSession in
                if let session = accountSession.session {
                    PoastTabView(account: accountSession.account)
                        .environmentObject(session)
                        .navigationBarBackButtonHidden(true)
                } else {
                    PoastSignInView(host: accountSession.account.host!.absoluteString, handle: accountSession.account.handle!, signInViewModel: PoastSignInViewModel())
                        .environmentObject(accountSession.account)
                }
            })
            .navigationTitle("Accounts")
            .toolbar {
                EditButton()
                Button {
                    self.showingSignInView = true
                } label: {
                    Image(systemName: "plus")
                }
                .navigationDestination(isPresented: $showingSignInView) {
                   PoastSignInView(signInViewModel: PoastSignInViewModel())
                }
            }
            .onAppear {
                self.accounts = self.accountsViewModel.getAccounts().sorted { $0.handle! > $1.handle! }
            }
        }
    }
}

#Preview {
    PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
}
