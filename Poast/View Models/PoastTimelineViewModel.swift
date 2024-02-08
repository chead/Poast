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
    func getTimeline(session: PoastSessionObject, cursor: Date) async -> Result<PoastTimelineModel, PoastTimelineViewModelError>
}

class PoastTimelinePreviewViewModel: PoastTimelineViewModeling {
    func getTimeline(session: PoastSessionObject, cursor: Date) async -> Result<PoastTimelineModel, PoastTimelineViewModelError> {
        return .success(PoastTimelineModel(posts: [
            PoastFeedViewPostModel(
                id: UUID(),
                uri: "",
                cid: "",
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
                parent: .post(PoastFeedPostViewModel(cid: "",
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
                                                     date: Date() - 1000,
                                                     like: nil,
                                                     repost: nil,
                                                     replyDisabled: false)),
                embed: PoastPostEmbedModel.images([
                    PoastPostEmbedImageModel(fullsize: "",
                                             thumb: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
                                             alt: "Some alt text",
                                             aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
                                                                                          height: 250)),
                    PoastPostEmbedImageModel(fullsize: "",
                                             thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg",
                                             alt: "Some alt text",
                                             aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
                                                                                          height: 250))
                ]),
                date: Date(timeIntervalSinceNow: -10),
                repostedBy: nil,
                like: nil,
                repost: nil,
                replyDisabled: false)
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

    func getTimeline(session: PoastSessionObject, cursor: Date) async -> Result<PoastTimelineModel, PoastTimelineViewModelError> {
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

                    switch(try await self.blueskyClient.getTimeline(host: account.host!,
                                                                    accessToken: credentials.accessToken,
                                                                    refreshToken: credentials.refreshToken,
                                                                    algorithm: algorithm,
                                                                    limit: 50,
                                                                    cursor: cursor)) {
                    case .success(let getTimelineResponse):
                        return .success(PoastTimelineModel(blueskyFeedFeedViewPosts: getTimelineResponse.body.feed))

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
}
