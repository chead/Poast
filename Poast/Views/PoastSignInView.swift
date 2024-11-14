//
//  PoastAddAccountView.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import SwiftUI
import SwiftData

struct PoastSignInView: View {
    @EnvironmentObject var user: UserModel

    let signInViewModel: PoastSignInViewModel

    @State var host: String
    @State var handle: String
    @State var password: String = ""

    @State private var loading: Bool = false
    @State private var showInvalidURLAlert: Bool = false
    @State private var showBlueskyBadUsernameOrPasswordAlert: Bool = false
    @State private var showBlueskyClientErrorAlert: Bool = false
    @State private var showCredentialsServiceErrorAlert: Bool = false
    @State private var showModelContextErrorAlert: Bool = false
    @State private var showUnknownErrorAlert: Bool = false

    init(host: String = "https://bsky.social", handle: String = "", signInViewModel: PoastSignInViewModel) {
        self.host = host
        self.handle = handle
        self.signInViewModel = signInViewModel
    }

    var isSignInButtonDisabled: Bool {
        loading == true || [host, handle, password].contains(where: \.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Host",
                      text: $host,
                      prompt: Text("Host").foregroundColor(.gray)
            )
            .textInputAutocapitalization(.never)
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
            .textInputAutocapitalization(.never)
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
            }
            .padding(.horizontal)

            Button {
                Task {
                    guard let hostURL = URL(string: self.host) else {
                        showInvalidURLAlert = true

                        return
                    }

                    loading = true

                    switch(await signInViewModel.signIn(host: hostURL, handle: handle, password: password)) {
                    case .success(let session):
                        user.session = session

                    case .failure(let signInError):
                        loading = false

                        switch(signInError) {
                        case .blueskyClient(error: let createSessionError):
                            switch(createSessionError) {
                            case .atProtoClient(let atProtoClientError):
                                switch(atProtoClientError) {
                                case .unauthorized:
                                    showBlueskyBadUsernameOrPasswordAlert = true

                                default:
                                    break
                                }

                            default:
                                showBlueskyClientErrorAlert = true
                            }

                        default:
                            showUnknownErrorAlert = true
                        }
                    }
                }
            } label: {
                Text("Sign In")
            }
            .frame(maxWidth: .infinity)
            .disabled(isSignInButtonDisabled)
            .padding()
            .alert("Invalid Host", isPresented: $showInvalidURLAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Bad username or password", isPresented: $showBlueskyBadUsernameOrPasswordAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Bluesky Client error", isPresented: $showBlueskyClientErrorAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Credentials Service error", isPresented: $showCredentialsServiceErrorAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Model Context error", isPresented: $showModelContextErrorAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Sign in failed", isPresented: $showUnknownErrorAlert) {
                Button("OK", role: .cancel) {}
            }

            Spacer()
        }
        .disabled(loading)
        .blur(radius: loading ? 3 : 0)
        .overlay {
            if loading == true {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .navigationTitle("Sign in")

    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AccountModel.self, configurations: config)

    PoastSignInView(signInViewModel: PoastSignInViewModel(modelContext: container.mainContext))
        .environmentObject(UserModel())
}
