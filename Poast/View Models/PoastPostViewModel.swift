//
//  PoastPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum PoastPostViewModelError: Error {
    case session
    case credentials
    case account
    case unknown
}

@MainActor class PoastPostViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

    @Published var post: PoastPostModel

    init(post: PoastPostModel) {
        self.post = post
    }

    var timeAgoString: String {
        guard post.date.timeIntervalSinceNow.rounded() != 0 else { return "now" }

        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .full

        return formatter.localizedString(for: post.date, relativeTo: Date())
    }

    func getPost(session: PoastSessionObject, uri: String) async -> Result<PoastPostModel?, PoastPostViewModelError> {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .failure(.session)
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentials)
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .failure(.account)
                    }

                    switch(try await self.blueskyClient.getPosts(host: account.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, uris: [uri])) {
                    case .success(let getPostsResponse):
                        if let credentials = getPostsResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
                                                                          accessToken: credentials.accessToken,
                                                                          refreshToken: credentials.refreshToken)
                        }
                        
                        if let post = getPostsResponse.body.posts.first {
                            return .success(PoastPostModel(blueskyFeedPostView: post))
                        } else {
                            return .success(nil)
                        }

                    case .failure(_):
                        return .failure(.unknown)
                    }

                case .failure(_):
                    return .failure(.unknown)
                }

            case .failure(_):
                return .failure(.unknown)
            }

        } catch(_) {
            return .failure(.unknown)
        }
    }

    func likePost(session: PoastSessionObject, uri: String, cid: String) async -> Result<ATProtoRepoStrongRef, PoastPostViewModelError> {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .failure(.session)
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentials)
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .failure(.account)
                    }

                    switch(try await self.blueskyClient.createLike(host: account.host!, 
                                                                   accessToken: credentials.accessToken,
                                                                   refreshToken: credentials.refreshToken,
                                                                   repo: sessionDid,
                                                                   uri: uri,
                                                                   cid: cid)) {
                    case .success(let createLikeResponse):
                        if let credentials = createLikeResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
                                                                          accessToken: credentials.accessToken,
                                                                          refreshToken: credentials.refreshToken)
                        }

                        return .success(ATProtoRepoStrongRef(uri: createLikeResponse.body.uri,
                                                             cid: createLikeResponse.body.cid))

                    case .failure(_):
                        return .failure(.unknown)
                    }

                case .failure(_):
                    return .failure(.unknown)
                }

            case .failure(_):
                return .failure(.unknown)
            }

        } catch(_) {
            return .failure(.unknown)
        }
    }

    func unlikePost(session: PoastSessionObject, rkey: String) async -> PoastPostViewModelError? {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .session
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .credentials
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .account
                    }

                    if(try await self.blueskyClient.deleteLike(host: account.host!,
                                                               accessToken: credentials.accessToken,
                                                               refreshToken: credentials.refreshToken,
                                                               repo: sessionDid,
                                                               rkey: rkey) != nil) {
                        return .unknown
                    } else {
                        return nil
                    }

                case .failure(_):
                    return .unknown
                }

            case .failure(_):
                return .unknown
            }

        } catch(_) {
            return .unknown
        }
    }
}
