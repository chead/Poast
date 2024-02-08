//
//  PoastTimelineModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastTimelineModel {
    let posts: [PoastPostModel]

    init(posts: [PoastPostModel]) {
        self.posts = posts
    }

    init(blueskyFeedFeedViewPosts: [BlueskyFeedFeedViewPost]) {
        self.posts = blueskyFeedFeedViewPosts.map { PoastPostModel(blueskyFeedFeedViewPost: $0) }
    }
}
