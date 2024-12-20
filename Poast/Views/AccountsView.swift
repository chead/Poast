//
//  AccountsView.swift
//  Poast
//
//  Created by Christopher Head on 1/1/24.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    let accountsViewModel: AccountsViewModel

    @Query private var accounts: [AccountModel]

    @State var selectedAccount: AccountModel?
    @State var showingSignInView: Bool = false

    var body: some View {
        NavigationStack() {
            List {
                ForEach(accounts) { account in
                    Button(action: {
                        user.session = account.session

                        selectedAccount = account
                    }) {
                        Text("\(account.handle) @ \(account.host.host()!)")
                    }
                }
                .onDelete { indexSet in 
                    indexSet.forEach {
                        _ = accountsViewModel.deleteAccount(account: self.accounts[$0])
                    }
                }
            }
            .navigationDestination(item: $selectedAccount, destination: { account in
                SignInView(host: account.host.absoluteString, handle: account.handle, signInViewModel: PoastSignInViewModel(modelContext: modelContext))
            })
            .navigationTitle("Accounts")
            .toolbar {
                if(!accounts.isEmpty) {
                    EditButton()
                }
                Button {
                    showingSignInView = true
                } label: {
                    Image(systemName: "plus")
                }
                .navigationDestination(isPresented: $showingSignInView) {
                    SignInView(signInViewModel: PoastSignInViewModel(modelContext: modelContext))
                }
            }
        }
    }
}

#Preview {
    let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: AccountModel.self, configurations: modelConfiguration)

    AccountsView(accountsViewModel: AccountsViewModel(modelContext: modelContainer.mainContext))
}
