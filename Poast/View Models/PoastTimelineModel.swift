//
//  PoastTimelineModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastTimelineModel {
    let posts: [PoastVisiblePostModel]

    init(posts: [PoastVisiblePostModel]) {
        self.posts = posts
    }

    init(blueskyFeedFeedViewPosts: [BlueskyFeedFeedViewPost]) {
        self.posts = blueskyFeedFeedViewPosts.map { PoastVisiblePostModel(blueskyFeedFeedViewPost: $0) }
    }
}
