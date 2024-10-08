//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import Foundation
import SwiftBluesky

class PoastFeedTimelineViewModel: PoastTimelineViewModel {
    let algorithm: String

    init(algorithm: String) {
        self.algorithm = algorithm
    }

    override func getTimeline(session: PoastSessionModel, cursor: Date) async -> PoastTimelineViewModelError? {
        do {
            switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .unknown
                }


                switch(try await self.blueskyClient.getTimeline(host: session.account.host,
                                                                accessToken: credentials.accessToken,
                                                                refreshToken: credentials.refreshToken,
                                                                algorithm: algorithm,
                                                                limit: 50,
                                                                cursor: cursor)) {
                case .success(let getTimelineResponse):
                    self.posts.append(contentsOf: getTimelineResponse.body.feed.map { PoastVisiblePostModel(blueskyFeedFeedViewPost: $0) })

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
