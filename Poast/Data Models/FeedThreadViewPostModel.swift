//
//  FeedThreadViewPost.swift
//  Poast
//
//  Created by Christopher Head on 2/18/24.
//

import SwiftBluesky

struct FeedThreadViewPostModel: Hashable {
    let post: FeedPostViewModel
    let parent: FeedThreadViewPostPostModel?
    let replies: [FeedThreadViewPostPostModel]?

    init(post: FeedPostViewModel, parent: FeedThreadViewPostPostModel?, replies: [FeedThreadViewPostPostModel]?) {
        self.post = post
        self.parent = parent
        self.replies = replies
    }

    init(threadViewPost: Bsky.Feed.ThreadViewPost) {
        self.post = FeedPostViewModel(postView: threadViewPost.post)

        if let parent = threadViewPost.parent {
            self.parent = FeedThreadViewPostPostModel(threadViewPostPostType: parent)
        } else {
            self.parent = nil
        }

        if let replies = threadViewPost.replies {
            self.replies = replies.map { FeedThreadViewPostPostModel(threadViewPostPostType: $0) }
        } else {
            self.replies = []
        }
    }
}
