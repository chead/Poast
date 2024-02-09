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

@MainActor class PoastTimelineViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

    @Published var posts: [PoastPostModel] = []

    let algorithm: String

    init(algorithm: String) {
        self.algorithm = algorithm
    }

    func getTimeline(session: PoastSessionObject, cursor: Date) async -> PoastTimelineViewModelError? {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .session
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .unknown
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .unknown
                    }

                    switch(try await self.blueskyClient.getTimeline(host: account.host!,
                                                                    accessToken: credentials.accessToken,
                                                                    refreshToken: credentials.refreshToken,
                                                                    algorithm: algorithm,
                                                                    limit: 50,
                                                                    cursor: cursor)) {
                    case .success(let getTimelineResponse):
                        self.posts.append(contentsOf: getTimelineResponse.body.feed.map { PoastPostModel(blueskyFeedFeedViewPost: $0) })

                    case .failure(_):
                        return .unknown
                    }

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
