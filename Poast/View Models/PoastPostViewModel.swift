//
//  PoastPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftBluesky

enum PoastPostViewModelError: Error {
    case session
    case credentials
    case account
    case unknown
}

class PoastPostViewModel {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

    func getTimeAgo(date: Date) -> String {
        guard date.timeIntervalSinceNow.rounded() != 0 else {
            return "now"
        }

        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .full

        return formatter.localizedString(for: date, relativeTo: Date())
    }

    func getPost(session: PoastSessionObject, uri: String) async -> Result<PoastFeedPostViewModel?, PoastPostViewModelError> {
        do {
            guard let sessionDid = session.did,
                  let accountUUID = session.accountUUID else {
                return .failure(.session)
            }

            switch(self.credentialsService.getCredentials(sessionDID: sessionDid)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentials)
                }

                switch(self.accountService.getAccount(uuid: accountUUID)) {
                case .success(let account):
                    guard let account = account else {
                        return .failure(.account)
                    }

                    switch(try await self.blueskyClient.getPosts(host: account.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, uris: [uri])) {
                    case .success(let getPostsResponseBody):
                        return .success(PoastFeedPostViewModel(blueSkyFeedPostView: getPostsResponseBody.posts.first!))

                    case .failure(let error):
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
