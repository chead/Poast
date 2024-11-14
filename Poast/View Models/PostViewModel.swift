//
//  PostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum PostViewModelError: Error {
    case noCredentials
    case credentialsService(error: PoastCredentialsServiceError)
    case blueskyClientGetPosts(error: BlueskyClientError<Bsky.Feed.GetPostsError>)
    case unknown(error: Error)
}

@MainActor
class PostViewModel {
    @Dependency private var credentialsService: PoastCredentialsService

    let post: FeedFeedViewPostModel

    init(post: FeedFeedViewPostModel) {
        self.post = post
    }

    var timeAgoString: String {
        guard post.date.timeIntervalSinceNow.rounded() != 0 else { return "now" }

        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .full

        return formatter.localizedString(for: post.date, relativeTo: Date())
    }

    func getPost(session: SessionModel, uri: String) async -> Result<FeedFeedViewPostModel?, PostViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getPosts(host: session.account.host,
                                            accessToken: credentials.accessToken,
                                            refreshToken: credentials.refreshToken,
                                            uris: [uri])) {
            case .success(let getPostsResponse):
                if let credentials = getPostsResponse.credentials {
                    _ = self.credentialsService.updateCredentials(did: session.did,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken)
                }

                if let postView = getPostsResponse.body.posts.first {
                    return .success(FeedFeedViewPostModel(postView: postView))
                } else {
                    return .success(nil)
                }

            case .failure(let error):
                return .failure(.blueskyClientGetPosts(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsService(error: error))
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
