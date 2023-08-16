//
//  PoastAddAccountView.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import SwiftUI

struct PoastSignInView: View {
    @ObservedObject var signInViewModel: PoastSignInViewModel

    @State var host: String = ""
    @State var handle: String = ""
    @State var password: String = ""
    @State var signedInSession: PoastSessionObject? = nil

    @State var showSessionView: Bool = false
    @State var showInvalidURLAlert: Bool = false
    @State var showUnauthorizedAlert: Bool = false
    @State var showHostUnreachableAlert: Bool = false
    @State var showUnknownErrorAlert: Bool = false

    @Binding var accounts: [PoastAccountObject]

    var isSignInButtonDisabled: Bool {
        [host, handle, password].contains(where: \.isEmpty)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                Spacer()

                TextField("Host",
                          text: $host,
                          prompt: Text("Host").foregroundColor(.blue)
                )
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                }
                .padding(.horizontal)
                
                TextField("Name",
                          text: $handle,
                          prompt: Text("Handle").foregroundColor(.blue)
                )
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                }
                .padding(.horizontal)

                SecureField("Password",
                            text: $password,
                            prompt: Text("Password").foregroundColor(.red)
                )
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: 2)
                }.padding(.horizontal)
                
                Spacer()
                
                Button {
                    Task {
                        guard let hostURL = URL(string: self.host) else {
                            self.showInvalidURLAlert = true

                            return
                        }

                        switch(await self.signInViewModel.signIn(host: hostURL, handle: self.handle, password: self.password)) {
                        case .success(let sessionObject):
                            self.signedInSession = sessionObject

                            self.accounts.append(sessionObject.account!)

                            self.showSessionView = true

                        case .failure(let error):
                            switch(error) {
                            case .authorization:
                                self.showUnauthorizedAlert = true

                            case .availability:
                                self.showHostUnreachableAlert = true

                            case .request, .service, .unknown:
                                self.showUnknownErrorAlert = true
                            }
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    isSignInButtonDisabled ?
                    LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .disabled(isSignInButtonDisabled)
                .padding()
                .navigationDestination(isPresented: $showSessionView) {
                    Text("Foobar")
//                    if let signedInAccount = self.signedInAccount {
//                        PoastTimelineView(timelineViewModel: PoastTimelineViewModel(account: signedInAccount, provider: DependencyProvider()))
//                    }
                }
                .alert("Invalid Host", isPresented: $showInvalidURLAlert) {
                    Button("OK", role: .cancel) {}
                }
                .alert("Invalid handle or password", isPresented: $showUnauthorizedAlert) {
                    Button("OK", role: .cancel) {}
                }
                .alert("Host unreachable", isPresented: $showHostUnreachableAlert) {
                    Button("OK", role: .cancel) {}
                }
                .alert("Sign in failed", isPresented: $showUnknownErrorAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
    }
}

struct PoastSignInView_Previews: PreviewProvider {
    static var previews: some View {
        PoastSignInView(signInViewModel: PoastSignInViewModel(provider: nil), accounts: .constant([]))
    }
}
