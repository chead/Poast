//
//  AuthorTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import Foundation
import SwiftData
import SwiftBluesky

class AuthorFeedViewModel: FeedViewModel {
    private let actor: String
    private let filter: Bsky.Feed.GetAuthorFeedFilter

    init(session: SessionModel, modelContext: ModelContext, actor: String, filter: Bsky.Feed.GetAuthorFeedFilter = .postsWithReplies) {
        self.actor = actor
        self.filter = filter

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[FeedFeedViewPostModel], FeedViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getAuthorFeed(host: session.account.host,
                                                 accessToken: credentials.accessToken,
                                                 refreshToken: credentials.refreshToken,
                                                 actor: actor,
                                                 cursor: cursor)) {
            case .success(let getAuthorFeedResponse):
                if let credentials = getAuthorFeedResponse.credentials {
                    _ = self.credentialsService.updateCredentials(did: session.did,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken)
                }

                return .success(getAuthorFeedResponse.body.feed.map { FeedFeedViewPostModel(feedViewPost: $0) })

            case .failure(let error):
                return .failure(.authorFeed(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsService(error: error))
        }
    }
}
