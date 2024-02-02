//
//  PoastPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastFeedViewPostModel: Hashable, Identifiable {
    static func == (lhs: PoastFeedViewPostModel, rhs: PoastFeedViewPostModel) -> Bool {
        lhs.id == rhs.id
    }

    var id: String
    var uri: String
    let text: String
    let author: PoastProfileModel
    let replyCount: Int
    let likeCount: Int
    let repostCount: Int
    let root: PoastReplyModel?
    let parent: PoastReplyModel?
    let date: Date
    
    init(id: String, uri: String, text: String, author: PoastProfileModel, replyCount: Int, likeCount: Int, repostCount: Int, root: PoastReplyModel?, parent: PoastReplyModel?, date: Date) {
        self.id = id
        self.uri = uri
        self.text = text
        self.author = author
        self.replyCount = replyCount
        self.likeCount = likeCount
        self.repostCount = repostCount
        self.root = root
        self.parent = parent
        self.date = date
    }

    init(blueskyFeedFeedViewPost: BlueskyFeedFeedViewPost) {
        self.id = blueskyFeedFeedViewPost.post.cid
        self.uri = blueskyFeedFeedViewPost.post.uri

        switch(blueskyFeedFeedViewPost.post.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text
        }

        self.author = PoastProfileModel(blueskyActorProfileViewBasic: blueskyFeedFeedViewPost.post.author)
        self.replyCount = blueskyFeedFeedViewPost.post.replyCount ?? 0
        self.repostCount = blueskyFeedFeedViewPost.post.repostCount ?? 0
        self.likeCount = blueskyFeedFeedViewPost.post.likeCount ?? 0

        switch(blueskyFeedFeedViewPost.post.embed) {
        default:
            break
        }

        if let parent = blueskyFeedFeedViewPost.reply?.parent {
            self.parent = PoastReplyModel(feedReplyRef: parent)
        } else {
            self.parent = nil
        }

        if let root = blueskyFeedFeedViewPost.reply?.root {
            self.root = PoastReplyModel(feedReplyRef: root)
        } else {
            self.root = nil
        }

        self.date = blueskyFeedFeedViewPost.post.indexedAt
    }
}
