//
//  PoastBlueskyService.swift
//  Poast
//
//  Created by Christopher Head on 8/6/23.
//

import Foundation
import SwiftBluesky

enum PoastBlueskyServiceError: Error {
    case clientRequest
    case clientResponse
    case clientAuthorization
    case clientAvailability

    case credentialsNotFound

    case accountService
    case credentialsService
    case sessionService

    case unknown

    init(blueskyClientError: BlueskyClientError) {
        switch(blueskyClientError) {
        case .invalidRequest:
            self = .clientRequest

        case .invalidResponse:
            self = .clientResponse

        case .unauthorized:
            self = .clientAuthorization

        case .unavailable:
            self = .clientAvailability

        case .unknown:
            self = .unknown
        }
    }
}

class PoastBlueskyService: ServiceRepresentable {
    private let blueskyClient: BlueskyClient!
    private let sessionService: PoastSessionService!
    private let credentialsService: PoastCredentialsService!
    private let accountService: PoastAccountService!
    
    required init(provider: DependencyProviding) {
        self.blueskyClient = provider.register()
        self.sessionService = provider.register(provider: provider)
        self.credentialsService = provider.register(provider: provider)
        self.accountService = provider.register(provider: provider)
    }
    
    func createSession(host: URL, handle: String, password: String) async -> Result<PoastSessionObject, PoastBlueskyServiceError> {
        do {
            switch(try await self.blueskyClient.createSession(host: host, identifier: handle, password: password)) {
            case .success(let createSessionResponseBody):
                switch(self.accountService.createAccount(host: host, handle: handle)) {
                case .success(let account):
                    switch(self.credentialsService.addCredentials(account: account, accessToken: createSessionResponseBody.accessJwt, refreshToken: createSessionResponseBody.refreshJwt)) {
                    case .success(let success):
                        switch(success) {
                        case true:
                            switch(self.sessionService.createSession(account: account)) {
                            case .success(let session):
                                return .success(session)

                            case .failure(_):
                                return .failure(.sessionService)
                            }

                        case false:
                            return(.failure(.credentialsService))
                        }

                    case .failure(_):
                        return(.failure(.credentialsService))
                    }

                case .failure(_):
                    return .failure(.accountService)
                }
            case .failure(let error):
                return .failure(PoastBlueskyServiceError(blueskyClientError: error))
            }
        } catch(_) {
            return .failure(.unknown)
        }
    }

    func refreshSession(session: PoastSessionObject) async -> Result<PoastSessionObject, PoastBlueskyServiceError> {
        do {
            switch(self.credentialsService.getCredentials(account: session.account!)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentialsNotFound)
                }

                switch(try await self.blueskyClient.refreshSession(host: session.account!.host!, refreshToken: credentials.refreshToken)) {
                case .success(let refreshSessionResponseBody):
                    switch(self.credentialsService.updateCredentials(account: session.account!, accessToken: refreshSessionResponseBody.accessJwt, refreshToken: refreshSessionResponseBody.refreshJwt)) {
                    case .success(let success):
                        switch(success) {
                        case true:
                            return .success(session)

                        case false:
                            return .failure(.credentialsService)
                        }

                    case .failure(_):
                        return .failure(.credentialsService)
                    }

                case .failure(let error):
                    return .failure(PoastBlueskyServiceError(blueskyClientError: error))
                }
            case .failure(_):
                return .failure(.credentialsService)
            }
        } catch(_) {
            return .failure(.unknown)
        }
    }

    func getProfiles(session: PoastSessionObject, actors: [String]) async -> Result<[PoastProfileModel], PoastBlueskyServiceError> {
        do {
            switch(self.credentialsService.getCredentials(account: session.account!)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentialsNotFound)
                }

                switch(try await self.blueskyClient.getProfiles(host: session.account!.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actors: actors)) {
                case .success(let getProfilesResponseBody):
                    return .success(getProfilesResponseBody.profiles.map { PoastProfileModel(blueskyActorProfileViewDetailed: $0) })

                case .failure(let error):
                    return .failure(PoastBlueskyServiceError(blueskyClientError: error))
                }

            case .failure(_):
                return .failure(.credentialsService)
            }
        } catch(_) {
            return .failure(.unknown)
        }
    }

    func getAuthorFeed(session: PoastSessionObject, actor: String, limit: Int, cursor: String) async -> Result<PoastTimelineModel, PoastBlueskyServiceError> {
        do {
            switch(self.credentialsService.getCredentials(account: session.account!)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentialsNotFound)
                }

                switch(try await self.blueskyClient.getAuthorFeed(host: session.account!.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actor: actor, limit: limit, cursor: cursor)) {
                case .success(let getAuthorFeedResponseBody):
                    return .success(PoastTimelineModel(blueskyFeedFeedViewPosts: getAuthorFeedResponseBody.feed))

                case .failure(let error):
                    return .failure(PoastBlueskyServiceError(blueskyClientError: error))
                }
            case .failure(_):
                return .failure(.credentialsService)
            }
        } catch(_) {
            return .failure(.unknown)
        }
    }
}
