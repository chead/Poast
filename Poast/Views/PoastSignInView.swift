//
//  PoastAddAccountView.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import SwiftUI

struct PoastSignInView: View {
    struct AccountSession: Hashable {
        var account: PoastAccountObject
        var session: PoastSessionObject
    }

    let signInViewModel: PoastSignInViewModel

    @State var host: String
    @State var handle: String
    @State var password: String = ""

    @State private var loading: Bool = false
    @State private var signedInAccountSession: AccountSession? = nil
    @State private var showInvalidURLAlert: Bool = false
    @State private var showAccountExistsAlert: Bool = false
    @State private var showSessionExistsAlert: Bool = false
    @State private var showUnauthorizedAlert: Bool = false
    @State private var showHostUnreachableAlert: Bool = false
    @State private var showUnknownErrorAlert: Bool = false

    init(host: String = "", handle: String = "", signInViewModel: PoastSignInViewModel) {
        self.host = host
        self.handle = handle
        self.signInViewModel = signInViewModel
    }

    var isSignInButtonDisabled: Bool {
        self.loading == true || [host, handle, password].contains(where: \.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()

            TextField("Host",
                      text: $host,
                      prompt: Text("Host").foregroundColor(.gray)
            )
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
            }
            .padding(.horizontal)

            TextField("Name",
                      text: $handle,
                      prompt: Text("Handle").foregroundColor(.gray)
            )
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
            }
            .padding(.horizontal)

            SecureField("Password",
                        text: $password,
                        prompt: Text("Password").foregroundColor(.gray)
            )
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
            }.padding(.horizontal)

            Spacer()

            Button {
                Task {
                    guard let hostURL = URL(string: self.host) else {
                        self.showInvalidURLAlert = true

                        return
                    }

                    self.loading = true

                    switch(await self.signInViewModel.signIn(host: hostURL, handle: self.handle, password: self.password)) {
                    case .success(let accountSession):
                        self.signedInAccountSession = AccountSession(account: accountSession.0, session: accountSession.1)

                    case .failure(let error):
                        self.loading = false

                        switch(error) {
                        case .accountExists:
                            self.showAccountExistsAlert = true

                        case .sessionExists:
                            self.showSessionExistsAlert = true

                        case .unauthorized:
                            self.showUnauthorizedAlert = true

                        case .unavailable:
                            self.showHostUnreachableAlert = true

                        default:
                            self.showUnknownErrorAlert = true
                        }
                    }
                }
            } label: {
                Text("Sign In")
            }
            .frame(maxWidth: .infinity)
            .disabled(isSignInButtonDisabled)
            .padding()
            .navigationDestination(item: self.$signedInAccountSession, destination: { accountSession in
                PoastTabView(account: accountSession.account)
                    .environmentObject(accountSession.session)
                    .navigationBarBackButtonHidden(true)

            })
            .alert("Invalid Host", isPresented: $showInvalidURLAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Invalid handle or password", isPresented: $showUnauthorizedAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Duplicate account", isPresented: $showAccountExistsAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Duplicate session", isPresented: $showSessionExistsAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Host unreachable", isPresented: $showHostUnreachableAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Sign in failed", isPresented: $showUnknownErrorAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .disabled(self.loading)
        .blur(radius: self.loading ? 3 : 0)
        .overlay {
            if self.loading == true {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .navigationTitle("Sign in")

    }
}

#Preview {
    PoastSignInView(signInViewModel: PoastSignInViewModel())
}
