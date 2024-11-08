//
//  PoastAddAccountViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import Foundation


import SwiftData
import SwiftBluesky

enum PoastSignInViewModelError: Error {
    case blueskyClientServerCreateSession(error: BlueskyClientError<BlueskyClient.Server.ATProtoServerCreateSessionError>)
    case credentialsServiceGetCredentials(error: PoastCredentialsServiceError)
    case credentialsServiceAddCredentials(error: PoastCredentialsServiceError)
    case modelContext
    case unknown(error: Error)
}

class PoastSignInViewModel {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var preferencesService: PoastPreferencesService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func signIn(host: URL, handle: String, password: String) async -> Result<PoastSessionModel, PoastSignInViewModelError> {
        do {
            switch(try await BlueskyClient.Server.createSession(host: host, identifier: handle, password: password)) {
            case .success(let createSessionResponseBody):
                switch(getOrCreateAccount(handle: handle, host: host)) {
                case .success(let account):
                    switch(createSession(did: createSessionResponseBody.did, account: account)) {
                    case .success(let session):
                        if let error = credentialsService.addCredentials(did: createSessionResponseBody.did, accessToken: createSessionResponseBody.accessJwt, refreshToken: createSessionResponseBody.refreshJwt) {
                            return .failure(.credentialsServiceAddCredentials(error: error))
                        } else {
                            try preferencesService.setActiveSessionDid(sessionDid: session.did)

                            return .success(session)
                        }

                    case .failure(let error):
                        return .failure(error)
                    }

                case .failure(let error):
                    return .failure(error)
                }

            case .failure(let error):
                return .failure(.blueskyClientServerCreateSession(error: error))
            }
        } catch(let error) {
            return .failure(.unknown(error: error))
        }
    }

    func getOrCreateAccount(handle: String, host: URL) -> Result<PoastAccountModel, PoastSignInViewModelError> {
        let accountsFetchDescriptor = FetchDescriptor<PoastAccountModel>(predicate: #Predicate { account in
            account.handle == handle && account.host == host
        })

        do {
            let accounts = try modelContext.fetch(accountsFetchDescriptor)

            if let account = accounts.first {
                return .success(account)
            } else {
                let account = PoastAccountModel(uuid: UUID(), created: Date(), handle: handle, host: host, session: nil)

                modelContext.insert(account)

                return .success(account)
            }
        } catch(let error){
            return .failure(.unknown(error: error))
        }
    }

    func createSession(did: String, account: PoastAccountModel) -> Result<PoastSessionModel, PoastSignInViewModelError> {
        let session = PoastSessionModel(account: account, did: did, created: Date())

        modelContext.insert(session)

        return .success(session)
    }
}
