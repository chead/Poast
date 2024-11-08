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
    case noCredentials
    case credentialsService(error: PoastCredentialsServiceError)
    case blueskyClient(error: BlueskyClientError<BlueskyClient.Feed.BlueskyFeedGetPostsError>)
    case unknown(error: Error)
}

class PoastPostViewModel {
    @Dependency private var credentialsService: PoastCredentialsService

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
                    return .failure(.noCredentials)
                }

                switch(try await BlueskyClient.Feed.getPosts(host: session.account.host,
                                                             accessToken: credentials.accessToken,
                                                             refreshToken: credentials.refreshToken,
                                                             uris: [uri])) {
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

                case .failure(let error):
                    return .failure(.blueskyClient(error: error))
                }

            case .failure(let error):
                return .failure(.credentialsService(error: error))
            }

        } catch(let error) {
            return .failure(.unknown(error: error))
        }
    }

    func canSharePost() -> Bool {
        !(post.author.labels?.contains(where: { label in
            label.val == "!no-unauthenticated"
        }) ?? true)
    }

    func postShareURL() -> URL? {
        guard let lastURICompoenentIndex = post.uri.lastIndex(of: "/") else { return nil }

        return URL(string: "https://bsky.app/profile/\(post.author.handle)/post/\(String(post.uri.suffix(from: lastURICompoenentIndex).dropFirst()))")
    }
}
