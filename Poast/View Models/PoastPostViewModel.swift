//
//  PoastPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum PoastPostViewModelError: Error {
    case session
    case credentials
    case account
    case unknown
}

class PoastPostViewModel {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var blueskyClient: BlueskyClient

    let post: PoastVisiblePostModel

    init(post: PoastVisiblePostModel) {
        self.post = post
    }

    var timeAgoString: String {
        guard post.date.timeIntervalSinceNow.rounded() != 0 else { return "now" }

        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .full

        return formatter.localizedString(for: post.date, relativeTo: Date())
    }

    func getPost(session: PoastSessionModel, uri: String) async -> Result<PoastVisiblePostModel?, PoastPostViewModelError> {
        do {
            switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .failure(.credentials)
                }

                switch(try await self.blueskyClient.getPosts(host: session.account.host, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, uris: [uri])) {
                case .success(let getPostsResponse):
                    if let credentials = getPostsResponse.credentials {
                        _ = self.credentialsService.updateCredentials(did: session.did,
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken)
                    }

                    if let post = getPostsResponse.body.posts.first {
                        return .success(PoastVisiblePostModel(blueskyFeedPostView: post))
                    } else {
                        return .success(nil)
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
