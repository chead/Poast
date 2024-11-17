//
//  ThreadViewPost.swift
//  Poast
//
//  Created by Christopher Head on 11/16/24.
//

import SwiftBluesky

extension Bsky.Feed.ThreadViewPost: @retroactive Equatable {
    public static func ==(lhs: Bsky.Feed.ThreadViewPost, rhs: Bsky.Feed.ThreadViewPost) -> Bool {
        return lhs.post.uri == rhs.post.uri
    }
}
