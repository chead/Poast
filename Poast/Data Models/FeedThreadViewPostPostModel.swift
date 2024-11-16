//
//  FeedThreadViewPostPost.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import SwiftBluesky

indirect enum FeedThreadViewPostPostModel: Hashable, Identifiable {
    var id: Self { return self }

    case blocked(BlockedPostModel)
    case notFound(NotFoundPostModel)
    case threadViewPost(FeedThreadViewPostModel)

    init(threadViewPostPostType: Bsky.Feed.ThreadViewPost.PostType) {
        switch(threadViewPostPostType) {
        case .blockedPost(let blockedPost):
            self = .blocked(BlockedPostModel(uri: blockedPost.uri, authorDid: blockedPost.author.did))

        case .notFoundPost(let notFoundPost):
            self = .notFound(NotFoundPostModel(uri: notFoundPost.uri))

        case .threadViewPost(let threadViewPost):
            self = .threadViewPost(FeedThreadViewPostModel(threadViewPost: threadViewPost))
        }
    }

    static func ==(lhs: FeedThreadViewPostPostModel, rhs: FeedThreadViewPostPostModel) -> Bool {
        switch(lhs, rhs) {
        case (.blocked(let lhsValue), .blocked(let rhsValue)):
            return lhsValue == rhsValue

        case (.notFound(let lhsValue), .notFound(let rhsValue)):
            return lhsValue == rhsValue

        case (.threadViewPost(let lhsValue), .threadViewPost(let rhsValue)):
            return lhsValue == rhsValue

        default:
            return false
        }
    }
}
