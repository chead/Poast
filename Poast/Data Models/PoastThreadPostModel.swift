//
//  PoastThreadPostModel.swift
//  Poast
//
//  Created by Christopher Head on 2/18/24.
//

import Foundation
import SwiftBluesky

struct PoastThreadPostModel: Hashable {
    let post: PoastVisiblePostModel
    let parent: PoastThreadModel?
    let replies: [PoastThreadModel]?

    init(post: PoastVisiblePostModel, parent: PoastThreadModel?, replies: [PoastThreadModel]?) {
        self.post = post
        self.parent = parent
        self.replies = replies
    }

    init(threadViewPost: Bsky.Feed.ThreadViewPost) {
        self.post = PoastVisiblePostModel(postView: threadViewPost.post)

        if let parent = threadViewPost.parent {
            self.parent = PoastThreadModel(threadViewPostPostType: parent)
        } else {
            self.parent = nil
        }

        if let replies = threadViewPost.replies {
            self.replies = replies.map { PoastThreadModel(threadViewPostPostType: $0) }
        } else {
            self.replies = []
        }
    }
}
