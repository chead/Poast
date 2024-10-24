//
//  PoastAuthorTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import Foundation
import SwiftData
import SwiftBluesky

class PoastAuthorTimelineViewModel: PoastTimelineViewModel {
    let actor: String

    init(session: PoastSessionModel, modelContext: ModelContext, actor: String) {
        self.actor = actor

        super.init(session: session, modelContext: modelContext)
    }

    override func getTimeline(cursor: Date) async -> PoastTimelineViewModelError? {
        do {
            switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .unknown
                }



                switch(try await self.blueskyClient.getAuthorFeed(host: session.account.host,
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

                    posts.append(contentsOf: getAuthorFeedResponse.body.feed.map { PoastVisiblePostModel(blueskyFeedFeedViewPost: $0) })

                case .failure(_):
                    return .unknown
                }

            case .failure(_):
                return .unknown
            }

        } catch(_) {
            return .unknown
        }

        return nil
    }
}
