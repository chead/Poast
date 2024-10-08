//
//  PoastPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastVisiblePostModel: Hashable, Identifiable {
    let id = UUID()
    let uri: String
    let cid: String
    let text: String
    let author: PoastProfileModel
    let replyCount: Int
    let likeCount: Int
    let repostCount: Int
    let root: PoastReplyModel?
    let parent: PoastReplyModel?
    let embed: PoastPostEmbedModel?
    let date: Date
    let repostedBy: PoastProfileModel?
    let like: String?
    let repost: String?
    let replyDisabled: Bool

    init(uri: String, cid: String, text: String, author: PoastProfileModel, replyCount: Int, likeCount: Int, repostCount: Int, root: PoastReplyModel?, parent: PoastReplyModel?, embed: PoastPostEmbedModel?, date: Date, repostedBy: PoastProfileModel?, like: String?, repost: String?, replyDisabled: Bool) {
        self.uri = uri
        self.cid = cid
        self.text = text
        self.author = author
        self.replyCount = replyCount
        self.likeCount = likeCount
        self.repostCount = repostCount
        self.root = root
        self.parent = parent
        self.embed = embed
        self.date = date
        self.repostedBy = repostedBy
        self.like = like
        self.repost = repost
        self.replyDisabled = replyDisabled
    }

    init(blueskyFeedFeedViewPost: BlueskyFeedFeedViewPost) {
        self.uri = blueskyFeedFeedViewPost.post.uri
        self.cid = blueskyFeedFeedViewPost.post.cid

        switch(blueskyFeedFeedViewPost.post.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text
        }

        self.author = PoastProfileModel(blueskyActorProfileViewBasic: blueskyFeedFeedViewPost.post.author)
        self.replyCount = blueskyFeedFeedViewPost.post.replyCount ?? 0
        self.repostCount = blueskyFeedFeedViewPost.post.repostCount ?? 0
        self.likeCount = blueskyFeedFeedViewPost.post.likeCount ?? 0

        if let parent = blueskyFeedFeedViewPost.reply?.parent {
            self.parent = PoastReplyModel(blueskyFeedReplyRefPostType: parent)
        } else {
            self.parent = nil
        }

        if let root = blueskyFeedFeedViewPost.reply?.root {
            self.root = PoastReplyModel(blueskyFeedReplyRefPostType: root)
        } else {
            self.root = nil
        }

        if let embed = blueskyFeedFeedViewPost.post.embed {
            self.embed = PoastPostEmbedModel(blueskyFeedPostViewEmbedType: embed)
        } else {
            self.embed = nil
        }

        self.date = blueskyFeedFeedViewPost.post.indexedAt

        if let reason = blueskyFeedFeedViewPost.reason {
            switch(reason) {
            case .blueskyFeedReasonRepost(let repost):
                self.repostedBy = PoastProfileModel(blueskyActorProfileViewBasic: repost.by)
            }
        } else {
            self.repostedBy = nil
        }

        if let viewerState = blueskyFeedFeedViewPost.post.viewer {
            self.like = viewerState.like
            self.repost = viewerState.repost
            self.replyDisabled = viewerState.replyDisabled ?? false
        } else {
            self.like = nil
            self.repost = nil
            self.replyDisabled = false
        }
    }

    init(blueskyFeedPostView: BlueskyFeedPostView) {
        self.uri = blueskyFeedPostView.uri
        self.cid = blueskyFeedPostView.cid

        switch(blueskyFeedPostView.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text

            if let reply = blueskyFeedPost.reply {
                self.root = .reference(PoastStrongReferenceModel(atProtoRepoStrongRef: reply.root))
                self.parent = .reference(PoastStrongReferenceModel(atProtoRepoStrongRef: reply.parent))
            } else {
                self.root = nil
                self.parent = nil
            }
        }

        self.author = PoastProfileModel(blueskyActorProfileViewBasic: blueskyFeedPostView.author)
        self.replyCount = blueskyFeedPostView.replyCount ?? 0
        self.repostCount = blueskyFeedPostView.repostCount ?? 0
        self.likeCount = blueskyFeedPostView.likeCount ?? 0
        self.embed = nil
        self.date = blueskyFeedPostView.indexedAt
        self.repostedBy = nil

        if let viewerState = blueskyFeedPostView.viewer {
            self.like = viewerState.like
            self.repost = viewerState.repost
            self.replyDisabled = viewerState.replyDisabled ?? false
        } else {
            self.like = nil
            self.repost = nil
            self.replyDisabled = false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
    
    static func ==(lhs: PoastVisiblePostModel, rhs: PoastVisiblePostModel) -> Bool {
        return lhs.uri == rhs.uri
    }
}
