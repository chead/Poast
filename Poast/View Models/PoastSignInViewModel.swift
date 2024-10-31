//
//  PoastAddAccountViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import Foundation

import SwiftBluesky
import SwiftUI
import SwiftData

enum PoastSignInViewModelError: Error {
    case unavailable
    case unauthorized
    case accountExists
    case sessionExists
    case unknown
    case database

    init(blueskyClientError: BlueskyClientError) {
        switch blueskyClientError {
        case .unavailable:
            self = .unavailable

        case .unauthorized:
            self = .unauthorized

        default:
            self = .unknown
        }
    }

    init(credentialsServiceError: PoastCredentialsServiceError) {
        switch credentialsServiceError {
        default:
            self = .unknown
        }
    }
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
            switch(try await BlueskyClient.createSession(host: host, identifier: handle, password: password)) {
            case .success(let createSessionResponseBody):
                switch(self.getOrCreateAccount(handle: handle, host: host)) {
                case .success(let account):
                    switch(self.createSession(did: createSessionResponseBody.did, account: account)) {
                    case .success(let session):
                        switch(self.credentialsService.addCredentials(did: createSessionResponseBody.did, accessToken: createSessionResponseBody.accessJwt, refreshToken: createSessionResponseBody.refreshJwt)) {
                        case .success(let success):
                            switch(success) {
                            case true:
                                try preferencesService.setActiveSessionDid(sessionDid: session.did)

                                return .success(session)

                            case false:
                                return .failure(.unknown)
                            }

                        case .failure(let error):
                            return .failure(PoastSignInViewModelError(credentialsServiceError: error))
                        }

                    case .failure(let error):
                        return .failure(error)
                    }

                case .failure(let error):
                    return .failure(error)
                }

            case .failure(let error):
                return .failure(PoastSignInViewModelError(blueskyClientError: error))
            }
        } catch {
            return .failure(.unknown)
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
        } catch {
            return .failure(.database)
        }
    }

    func createSession(did: String, account: PoastAccountModel) -> Result<PoastSessionModel, PoastSignInViewModelError> {
        let session = PoastSessionModel(account: account, did: did, created: Date())

        modelContext.insert(session)

        return .success(session)
    }
}
