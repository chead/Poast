//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/10/24.
//

import Foundation
import SwiftATProto
import SwiftBluesky

@MainActor protocol PoastPostHosting {
    var credentialsService: PoastCredentialsService { get }
    var accountService: PoastAccountService { get }
    var blueskyClient: BlueskyClient { get }

    func replacePost(post: PoastPostModel, with: PoastPostModel)
    func toggleLikePost(session: PoastSessionObject, post: PoastPostModel) async
    func toggleRepostPost(session: PoastSessionObject, post: PoastPostModel) async
}

extension PoastPostHosting {
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

    func unlikePost(session: PoastSessionObject, uri: String) async -> PoastPostViewModelError? {
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

                    let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

                    if(try await self.blueskyClient.deleteLike(host: account.host!,
                                                               accessToken: credentials.accessToken,
                                                               refreshToken: credentials.refreshToken,
                                                               repo: sessionDid,
                                                               rkey: String(rkey)) != nil) {
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

    func toggleLikePost(session: PoastSessionObject, post: PoastPostModel) async {
        if(post.like != nil) {
            if(await unlikePost(session: session,
                                uri: post.like ?? "") == nil) {
                let mutablePost = PoastMutablePost(postModel: post)

                mutablePost.like = nil
                mutablePost.likeCount -= 1

                let mutatedPost = mutablePost.immutableCopy

                replacePost(post: post,
                            with: mutatedPost)
            }
        } else {
            switch(await likePost(session: session,
                                  uri: post.uri,
                                  cid: post.cid)) {
            case.success(let like):
                let mutablePost = PoastMutablePost(postModel: post)

                mutablePost.like = like.uri
                mutablePost.likeCount += 1

                let mutatedPost = mutablePost.immutableCopy

                replacePost(post: post,
                            with: mutatedPost)

                break

            case .failure(_):
                break
            }
        }
    }

    func repostPost(session: PoastSessionObject, uri: String, cid: String) async -> Result<ATProtoRepoStrongRef, PoastPostViewModelError> {
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

                    switch(try await self.blueskyClient.createRepost(host: account.host!,
                                                                     accessToken: credentials.accessToken,
                                                                     refreshToken: credentials.refreshToken,
                                                                     repo: sessionDid,
                                                                     uri: uri,
                                                                     cid: cid)) {

                    case .success(let createRepostResponse):
                        if let credentials = createRepostResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
                                                                          accessToken: credentials.accessToken,
                                                                          refreshToken: credentials.refreshToken)
                        }

                        return .success(ATProtoRepoStrongRef(uri: createRepostResponse.body.uri,
                                                             cid: createRepostResponse.body.cid))

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

    func unrepostPost(session: PoastSessionObject, uri: String) async -> PoastPostViewModelError? {
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

                    let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

                    if(try await self.blueskyClient.deleteRepost(host: account.host!,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken,
                                                                 repo: sessionDid,
                                                                 rkey: String(rkey)) != nil) {
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

    func toggleRepostPost(session: PoastSessionObject, post: PoastPostModel) async {
        if(post.repost != nil) {
            if(await unrepostPost(session: session,
                                  uri: post.repost ?? "") == nil) {
                let mutablePost = PoastMutablePost(postModel: post)

                mutablePost.repost = nil
                mutablePost.repostCount -= 1

                let mutatedPost = mutablePost.immutableCopy

                replacePost(post: post,
                            with: mutatedPost)
            }
        } else {
            switch(await repostPost(session: session,
                                    uri: post.uri,
                                    cid: post.cid)) {
            case.success(let repost):
                let mutablePost = PoastMutablePost(postModel: post)

                mutablePost.repost = repost.uri
                mutablePost.repostCount += 1

                let mutatedPost = mutablePost.immutableCopy

                replacePost(post: post,
                            with: mutatedPost)

            case .failure(_):
                break
            }
        }
    }
}

enum PoastTimelineViewModelError: Error {
    case session
    case unknown
}

@MainActor class PoastTimelineViewModel: ObservableObject, PoastPostHosting {
    @Dependency internal var credentialsService: PoastCredentialsService
    @Dependency internal var accountService: PoastAccountService
    @Dependency internal var blueskyClient: BlueskyClient

    @Published var posts: [PoastPostModel] = []

    func replacePost(post: PoastPostModel, with: PoastPostModel) {}

    func clearTimeline() {
        posts.removeAll()
    }

    func getTimeline(session: PoastSessionObject, cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }
}
