//
//  PoastAuthorLikesViewModel.swift
//  Poast
//
//  Created by Christopher Head on 10/30/24.
//

import Foundation
import SwiftData
import SwiftBluesky

class PoastLikesFeedViewModel: PoastFeedViewModel {
    private let actor: String

    init(session: PoastSessionModel, modelContext: ModelContext, actor: String) {
        self.actor = actor

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[PoastVisiblePostModel], PoastFeedViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .failure(.noCredentials)
            }

            do {
                switch(try await BlueskyClient.Feed.getActorLikes(host: session.account.host,
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

                    return .success(getAuthorFeedResponse.body.feed.map { PoastVisiblePostModel(blueskyFeedFeedViewPost: $0) })

                case .failure(let error):
                    return .failure(.blueskyClientFeedGetActorLikesFeed(error: error))
                }
            } catch(let error) {
                return .failure(.unknown(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsServiceGetCredentials(error: error))
        }
    }
}
