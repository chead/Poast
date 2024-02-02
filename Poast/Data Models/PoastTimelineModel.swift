//
//  PoastTimelineModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastTimelineModel {
    let posts: [PoastFeedViewPostModel]

    init(posts: [PoastFeedViewPostModel]) {
        self.posts = posts
    }

    init(blueskyFeedFeedViewPosts: [BlueskyFeedFeedViewPost]) {
        self.posts = blueskyFeedFeedViewPosts.map { PoastFeedViewPostModel(blueskyFeedFeedViewPost: $0) }
    }
}
