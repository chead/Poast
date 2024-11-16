//
//  FeedViewPost.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import Foundation
import SwiftBluesky

extension Bsky.Feed.FeedViewPost: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(post.uri)
    }
}

extension Bsky.Feed.FeedViewPost: @retroactive Equatable {
    public static func ==(lhs: Bsky.Feed.FeedViewPost, rhs: Bsky.Feed.FeedViewPost) -> Bool {
        return lhs.post.uri == rhs.post.uri
    }
}

extension Bsky.Feed.FeedViewPost: @retroactive Identifiable {
    public var id: String { post.uri }
}
