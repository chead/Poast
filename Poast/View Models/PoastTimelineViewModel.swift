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
        let authorOne = PoastProfileModel(did: "",
                                       handle: "weed.cum",
                                       displayName: "Weedlord",
                                       description: "Lorem Ipsum",
                                       avatar: "",
                                       banner: "",
                                       followsCount: 10,
                                       followersCount: 123,
                                       postsCount: 4123,
                                       labels: [])

        let authorTwo = PoastProfileModel(did: "",
                                       handle: "foobar.net",
                                       displayName: "Foobar",
                                       description: "Lorem Ipsum",
                                       avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                                       banner: "",
                                       followsCount: 10,
                                       followersCount: 123,
                                       postsCount: 4123,
                                       labels: [])

        let rootPost = PoastPostModel(id: "0",
                                      uri: "foo",
                                      text: "Root post",
                                      author: authorOne,
                                      replyCount: 1,
                                      repostCount: 0,
                                      likeCount: 10,
                                      root: nil,
                                      parent: nil,
                                      date: Date(timeIntervalSinceNow: -1000))

        let parentPost = PoastPostModel(id: "1",
                                        uri: "",
                                        text: "Parent post",
                                        author: authorTwo,
                                        replyCount: 1,
                                        repostCount: 0,
                                        likeCount: 10,
                                        root: .reference(uri: "foo", cid: ""),
                                        parent: .reference(uri: "foo", cid: ""),
                                        date: Date(timeIntervalSinceNow: -10))

        let firstPost = PoastPostModel(id: "2",
                                       uri: "",
                                       text: "First post",
                                       author: authorTwo,
                                       replyCount: 1,
                                       repostCount: 0,
                                       likeCount: 10,
                                       root: nil,
                                       parent: .post(parentPost),
                                       date: Date())

        let secondPost = PoastPostModel(id: "3",
                                        uri: "",
                                        text: "Second post",
                                        author: authorTwo,
                                        replyCount: 1,
                                        repostCount: 0,
                                        likeCount: 10,
                                        root: nil,
                                        parent: nil,
                                        date: Date())

        let timeline = PoastTimelineModel(posts: [firstPost, secondPost])

        return .success(timeline)
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
