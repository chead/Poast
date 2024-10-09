//
//  PoastAccountsView.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import SwiftUI
import SwiftData

struct PoastAccountsView: View {
    @Environment(\.modelContext) private var modelContext

    let accountsViewModel: PoastAccountsViewModel

    @Query private var accounts: [PoastAccountModel]

    @State var selectedAccount: PoastAccountModel?
    @State var showingSignInView: Bool = false

    var body: some View {
        NavigationStack() {
            List {
                ForEach(accounts) { account in
                    VStack {
                        Button(action: {
                            if let session = account.session {
                                _ = self.accountsViewModel.setActiveSession(session: session)
                            } else {
                                selectedAccount = account
                            }
                        }) {
                            Text("\(account.handle) @ \(account.host.host()!)")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { _ = accountsViewModel.deleteAccount(account: self.accounts[$0]) }
                }
            }
            .navigationDestination(item: $selectedAccount, destination: { account in
                PoastSignInView(host: account.host.absoluteString, handle: account.handle, signInViewModel: PoastSignInViewModel(modelContext: modelContext))
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
                    PoastSignInView(signInViewModel: PoastSignInViewModel(modelContext: modelContext))
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PoastAccountModel.self, configurations: config)

    PoastAccountsView(accountsViewModel: PoastAccountsViewModel(modelContext: container.mainContext))
}
