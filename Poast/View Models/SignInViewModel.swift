//
//  PoastAddAccountViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import Foundation


import SwiftData
import SwiftBluesky

enum SignInViewModelError: Error {
    case blueskyClient(error: BlueskyClientError<ATProto.Server.CreateSessionError>)
    case credentialsService(error: PoastCredentialsServiceError)
    case modelContext(error: Error)
}

class PoastSignInViewModel {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var preferencesService: PoastPreferencesService

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func signIn(host: URL, handle: String, password: String) async -> Result<SessionModel, SignInViewModelError> {
        switch(await ATProto.Server.createSession(host: host, identifier: handle, password: password)) {
        case .success(let createSessionResponseBody):
            switch(getOrCreateAccount(handle: handle, host: host)) {
            case .success(let account):
                switch(createSession(did: createSessionResponseBody.did, account: account)) {
                case .success(let session):
                    if let error = credentialsService.addCredentials(did: createSessionResponseBody.did, accessToken: createSessionResponseBody.accessJwt, refreshToken: createSessionResponseBody.refreshJwt) {
                        return .failure(.credentialsService(error: error))
                    } else {
                        preferencesService.setActiveSessionDid(sessionDid: session.did)

                        return .success(session)
                    }

                case .failure(let error):
                    return .failure(error)
                }

            case .failure(let error):
                return .failure(error)
            }

        case .failure(let error):
            return .failure(.blueskyClient(error: error))
        }
    }

    func getOrCreateAccount(handle: String, host: URL) -> Result<AccountModel, SignInViewModelError> {
        let accountsFetchDescriptor = FetchDescriptor<AccountModel>(predicate: #Predicate { account in
            account.handle == handle && account.host == host
        })

        do {
            let accounts = try modelContext.fetch(accountsFetchDescriptor)

            if let account = accounts.first {
                return .success(account)
            } else {
                let account = AccountModel(uuid: UUID(), created: Date(), handle: handle, host: host, session: nil)

                modelContext.insert(account)

                do {
                    try modelContext.save()
                } catch(let error) {
                    return .failure(.modelContext(error: error))
                }

                return .success(account)
            }
        } catch(let error) {
            return .failure(.modelContext(error: error))
        }
    }

    func createSession(did: String, account: AccountModel) -> Result<SessionModel, SignInViewModelError> {
        let session = SessionModel(account: account, did: did, created: Date())

        modelContext.insert(session)

        do {
            try modelContext.save()
        } catch(let error) {
            return .failure(.modelContext(error: error))
        }

        return .success(session)
    }
}
