//
//  PoastListsViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/9/24.
//

import SwiftUI

@MainActor
class PoastListsViewModel: ObservableObject {
    let session: PoastSessionModel

    init(session: PoastSessionModel) {
        self.session = session
    }

//    override func getPosts(cursor: Date) async -> Result<[PoastVisiblePostModel], PoastFeedViewModelError> {
//        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
//        case .success(let credentials):
//            guard let credentials = credentials else {
//                return .failure(.noCredentials)
//            }
//
//            do {
//                switch(try await BlueskyClient.Feed.getTimeline(host: session.account.host,
//                                                                accessToken: credentials.accessToken,
//                                                                refreshToken: credentials.refreshToken,
//                                                                algorithm: algorithm,
//                                                                limit: 50,
//                                                                cursor: cursor)) {
//                case .success(let getTimelineResponse):
//                    return .success(getTimelineResponse.body.feed.map {
//                        PoastVisiblePostModel(blueskyFeedFeedViewPost: $0)
//                    })
//
//                case .failure(let error):
//                    return .failure(.blueskyClientFeedGetTimelineFeed(error: error))
//                }
//            } catch(let error) {
//                return .failure(.unknown(error: error))
//            }
//
//        case .failure(let error):
//            return .failure(.credentialsServiceGetCredentials(error: error))
//        }
//    }
}
