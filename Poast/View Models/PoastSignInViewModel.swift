//
//  PoastAddAccountViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import Foundation

import SwiftBluesky

enum PoastSignInViewModelError: Error {
    case unavailable
    case unauthorized
    case accountExists
    case sessionExists
    case unknown

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

    init(accountServiceError: PoastAccountServiceError) {
        switch accountServiceError {
        case .accountExists:
            self = .accountExists

        default:
            self = .unknown
        }
    }

    init(sessionServiceError: PoastSessionServiceError) {
        switch sessionServiceError {
        case .sessionExists:
            self = .sessionExists
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
    @Dependency private var blueskyClient: BlueskyClient
    @Dependency private var accountService: PoastAccountService
    @Dependency private var sessionService: PoastSessionService
    @Dependency private var credentialsService: PoastCredentialsService
    
    func signIn(host: URL, handle: String, password: String) async -> Result<(PoastAccountObject, PoastSessionObject), PoastSignInViewModelError> {
        do {
            switch(try await self.blueskyClient.createSession(host: host, identifier: handle, password: password)) {
            case .success(let createSessionResponseBody):
                switch(self.accountService.getOrCreateAccount(host: host, handle: handle)) {
                case .success(let account):
                    switch(self.sessionService.createSession(did: createSessionResponseBody.did, accountUUID: account.uuid!)) {
                    case .success(let session):
                        switch(self.credentialsService.addCredentials(did: createSessionResponseBody.did, accessToken: createSessionResponseBody.accessJwt, refreshToken: createSessionResponseBody.refreshJwt)) {
                        case .success(let success):
                            switch(success) {
                            case true:
                                self.sessionService.setActiveSession(session: session)

                                return .success((account, session))

                            case false:
                                return .failure(.unknown)
                            }

                        case .failure(let error):
                            return .failure(PoastSignInViewModelError(credentialsServiceError: error))
                        }

                    case .failure(let error):
                        return .failure(PoastSignInViewModelError(sessionServiceError: error))
                    }

                case .failure(let error):
                    return .failure(PoastSignInViewModelError(accountServiceError: error))
                }

            case .failure(let error):
                return .failure(PoastSignInViewModelError(blueskyClientError: error))
            }
        } catch {
            return .failure(.unknown)
        }
    }

    func getAccount(uuid: UUID) -> Result<PoastAccountObject?, PoastSignInViewModelError> {
        switch(accountService.getAccount(uuid: uuid)) {
        case .success(let account):
            return .success(account)

        case .failure(let error):
            return.failure(PoastSignInViewModelError(accountServiceError: error))
        }
    }
}
