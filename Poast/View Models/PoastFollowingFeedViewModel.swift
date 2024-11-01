//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import Foundation
import SwiftData
import SwiftBluesky

@MainActor
class PoastFollowingFeedViewModel: PoastFeedViewModel {
    let algorithm: String

    init(session: PoastSessionModel, modelContext: ModelContext, algorithm: String = "") {
        self.algorithm = algorithm

        super.init(session: session, modelContext: modelContext)
    }

    override func getPosts(cursor: Date) async -> Result<[PoastVisiblePostModel], PoastTimelineViewModelError> {
        do {
            switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.unknown)
                }


                switch(try await BlueskyClient.getTimeline(host: session.account.host,
                                                                accessToken: credentials.accessToken,
                                                                refreshToken: credentials.refreshToken,
                                                                algorithm: algorithm,
                                                                limit: 50,
                                                                cursor: cursor)) {
                case .success(let getTimelineResponse):
                    return .success(getTimelineResponse.body.feed.map {
                        PoastVisiblePostModel(blueskyFeedFeedViewPost: $0)
                    })

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
