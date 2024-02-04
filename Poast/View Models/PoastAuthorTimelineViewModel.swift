//
//  PoastAuthorTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import Foundation
import SwiftBluesky

class PoastAuthorTimelineViewModel: PoastTimelineViewModeling {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

   let actor: String

    init(actor: String) {
        self.actor = actor
    }

    func getTimeline(session: PoastSessionObject, cursor: Date?) async -> Result<PoastTimelineModel, PoastTimelineViewModelError> {
        do {
            guard session.did != nil,
                  session.accountUUID != nil
            else {
                return .failure(.session)
            }

            switch(self.credentialsService.getCredentials(sessionDID: session.did!)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.unknown)
                }

                switch(self.accountService.getAccount(uuid: session.accountUUID!)) {
                case .success(let account):
                    guard let account = account else {
                        return .failure(.unknown)
                    }

                    switch(try await self.blueskyClient.getAuthorFeed(host: account.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actor: actor, limit: 50, cursor: "")) {
                    case .success(let getAuthorFeedResponse):
                        if let credentials = getAuthorFeedResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
                                                                          accessToken: credentials.accessToken,
                                                                          refreshToken: credentials.refreshToken)
                        }

                        return .success(PoastTimelineModel(blueskyFeedFeedViewPosts: getAuthorFeedResponse.body.feed))

                    case .failure(_):
                        return .failure(.unknown)
                    }

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
