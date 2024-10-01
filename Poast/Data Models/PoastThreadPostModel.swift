//
//  PoastThreadPostModel.swift
//  Poast
//
//  Created by Christopher Head on 2/18/24.
//

import Foundation
import SwiftBluesky

class PoastMutableThreadPost {
    var post: PoastPostModel
    var parent: PoastThreadModel?
    var replies: [PoastThreadModel]?

    init(threadPostModel: PoastThreadPostModel) {
        self.post = threadPostModel.post
        self.parent = threadPostModel.parent
        self.replies = threadPostModel.replies
    }

    var immutableCopy: PoastThreadPostModel {
        return PoastThreadPostModel(post: post,
                                    parent: parent,
                                    replies: replies)
    }
}

struct PoastThreadPostModel: Hashable {
    let post: PoastPostModel
    let parent: PoastThreadModel?
    let replies: [PoastThreadModel]?

    init(post: PoastPostModel, parent: PoastThreadModel?, replies: [PoastThreadModel]?) {
        self.post = post
        self.parent = parent
        self.replies = replies
    }

    init(blueskyFeedThreadViewPost: BlueskyFeedThreadViewPost) {
        self.post = PoastPostModel(blueskyFeedPostView: blueskyFeedThreadViewPost.post)

        if let parent = blueskyFeedThreadViewPost.parent {
            self.parent = PoastThreadModel(blueskyFeedThreadViewPostPostType: parent)
        } else {
            self.parent = nil
        }

        if let replies = blueskyFeedThreadViewPost.replies {
            self.replies = replies.map { PoastThreadModel(blueskyFeedThreadViewPostPostType: $0) }
        } else {
            self.replies = []
        }
    }
}
