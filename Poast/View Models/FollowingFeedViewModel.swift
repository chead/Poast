//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import Foundation
import SwiftData
import SwiftBluesky

class FollowingFeedViewModel: FeedViewModel {
    let algorithm: String

    init(session: SessionModel, modelContext: ModelContext, algorithm: String = "") {
        self.algorithm = algorithm

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[FeedFeedViewPostModel], FeedViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getTimeline(host: session.account.host,
                                               accessToken: credentials.accessToken,
                                               refreshToken: credentials.refreshToken,
                                               algorithm: algorithm,
                                               limit: 50,
                                               cursor: cursor)) {
            case .success(let getTimelineResponse):
                return .success(getTimelineResponse.body.feed.map {
                    FeedFeedViewPostModel(feedViewPost: $0)
                })

            case .failure(let error):
                return .failure(.followingFeed(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsService(error: error))
        }
    }
}
