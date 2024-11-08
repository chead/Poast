//
//  PoastAuthorTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import Foundation
import SwiftData
import SwiftBluesky

class PoastAuthorFeedViewModel: PoastFeedViewModel {
    private let actor: String
    private let filter: BlueskyClient.Feed.AuthorFeedFilter

    init(session: PoastSessionModel, modelContext: ModelContext, actor: String, filter: BlueskyClient.Feed.AuthorFeedFilter = .postsWithReplies) {
        self.actor = actor
        self.filter = filter

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[PoastVisiblePostModel], PoastFeedViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .failure(.noCredentials)
            }

            do {
                switch(try await BlueskyClient.Feed.getAuthorFeed(host: session.account.host,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken,
                                                                  actor: actor,
                                                                  filter: filter,
                                                                  limit: 50,
                                                                  cursor: cursor)) {
                case .success(let getAuthorFeedResponse):
                    if let credentials = getAuthorFeedResponse.credentials {
                        _ = self.credentialsService.updateCredentials(did: session.did,
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken)
                    }

                    return .success(getAuthorFeedResponse.body.feed.map { PoastVisiblePostModel(blueskyFeedFeedViewPost: $0) })

                case .failure(let error):
                    return .failure(.blueskyClientFeedGetAuthorFeed(error: error))
                }
            } catch(let error) {
                return .failure(.unknown(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsServiceGetCredentials(error: error))
        }
    }
}
