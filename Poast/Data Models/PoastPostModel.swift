//
//  PoastPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

//enum PoastPostModelReplyType: Hashable {
//    case reference(uri: String, cid: String)
//    case reply(PoastReplyModel)
//}

class PoastPostModel: Hashable, Equatable, Identifiable {
    static func == (lhs: PoastPostModel, rhs: PoastPostModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

    init(id: String, uri: String, text: String, author: PoastProfileModel, replyCount: Int, repostCount: Int, likeCount: Int, root: PoastReplyModel?, parent: PoastReplyModel?, date: Date) {
        self.id = id
        self.uri = uri
        self.text = text
        self.author = author
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.likeCount = likeCount
        self.root = root
        self.parent = parent
        self.date = date
    }

    init(blueSkyFeedPostView: BlueskyFeedPostView) {
        self.id = blueSkyFeedPostView.cid
        self.uri = blueSkyFeedPostView.uri

        switch(blueSkyFeedPostView.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text

            if let reply = blueskyFeedPost.reply {
                self.root = .reference(uri: reply.root.uri, cid: reply.root.cid)
                self.parent = .reference(uri: reply.parent.uri, cid: reply.parent.cid)
            } else {
                self.root = nil
                self.parent = nil
            }
        }

        self.author = PoastProfileModel(blueskyActorProfileViewBasic: blueSkyFeedPostView.author)
        self.replyCount = blueSkyFeedPostView.replyCount ?? 0
        self.repostCount = blueSkyFeedPostView.repostCount ?? 0
        self.likeCount = blueSkyFeedPostView.likeCount ?? 0
        self.date = blueSkyFeedPostView.indexedAt
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
