//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import Foundation
import SwiftBluesky

enum PoastTimelineViewModelError: Error {
    case session
    case unknown
}

protocol PoastTimelineViewModeling {
    func getTimeline(session: PoastSessionObject) async -> Result<PoastTimelineModel, PoastTimelineViewModelError>
}

class PoastTimelinePreviewViewModel: PoastTimelineViewModeling {
    func getTimeline(session: PoastSessionObject) async -> Result<PoastTimelineModel, PoastTimelineViewModelError> {
        return .success(PoastTimelineModel(posts: [
            PoastFeedViewPostModel(
                id: "",
                uri: "",
                text: "Child post",
                author: PoastProfileModel(
                    did: "",
                    handle: "foobar.net",
                    displayName: "Fooooooooooooooo bar",
                    description: "Lorem Ipsum",
                    avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                    banner: "",
                    followsCount: 10,
                    followersCount: 123,
                    postsCount: 4123,
                    labels: []),
                replyCount: 1,
                likeCount: 0,
                repostCount: 10,
                root: nil,
                parent: .post(PoastFeedPostViewModel(id: "",
                                                     uri: "",
                                                     text: "Parent post",
                                                     author: PoastProfileModel(
                                                        did: "",
                                                        handle: "barbaz.net",
                                                        displayName: "Barbaz",
                                                        description: "Lorem Ipsum",
                                                        avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                                                        banner: "",
                                                        followsCount: 1,
                                                        followersCount: 3,
                                                        postsCount: 551,
                                                        labels: []),
                                                     replyCount: 0,
                                                     likeCount: 0,
                                                     repostCount: 0,
                                                     root: nil,
                                                     parent: nil,
                                                     date: Date() - 1000)),
                date: Date(timeIntervalSinceNow: -10))
        ]))
    }
}

class PoastTimelineViewModel: PoastTimelineViewModeling {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

   let algorithm: String

    init(algorithm: String) {
        self.algorithm = algorithm
    }

    func getTimeline(session: PoastSessionObject) async -> Result<PoastTimelineModel, PoastTimelineViewModelError> {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .failure(.session)
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.unknown)
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .failure(.unknown)
                    }

                    switch(try await self.blueskyClient.getTimeline(host: account.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, algorithm: algorithm, limit: 50, cursor: "")) {
                    case .success(let getTimelineResponseBody):
                        return .success(PoastTimelineModel(blueskyFeedFeedViewPosts: getTimelineResponseBody.feed))

                    case .failure(let error):
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
}
