//
//  PoastAuthorLikesViewModel.swift
//  Poast
//
//  Created by Christopher Head on 10/30/24.
//

import Foundation
import SwiftData
import SwiftBluesky

class LikesFeedViewModel: FeedViewModel {
    private let actor: String

    init(session: SessionModel, modelContext: ModelContext, actor: String) {
        self.actor = actor

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[FeedFeedViewPostModel], FeedViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getActorLikes(host: session.account.host,
                                                 accessToken: credentials.accessToken,
                                                 refreshToken: credentials.refreshToken,
                                                 actor: actor,
                                                 limit: 50,
                                                 cursor: cursor)) {
            case .success(let getAuthorFeedResponse):
                if let credentials = getAuthorFeedResponse.credentials {
                    _ = self.credentialsService.updateCredentials(did: session.did,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken)
                }

                return .success(getAuthorFeedResponse.body.feed.map { FeedFeedViewPostModel(feedViewPost: $0) })

            case .failure(let error):
                return .failure(.actorLikesFeed(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsService(error: error))
        }
    }
}
