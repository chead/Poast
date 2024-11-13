//
//  FeedViewPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct FeedViewPostModel: Hashable, Identifiable {
    let id = UUID()
    let uri: String
    let cid: String
    let text: String
    let author: ProfileViewModel
    let replyCount: Int
    let likeCount: Int
    let repostCount: Int
    let root: PoastReplyModel?
    let parent: PoastReplyModel?
    let embed: PoastPostEmbedModel?
    let date: Date
    let repostedBy: ProfileViewModel?
    let like: String?
    let repost: String?
    let threadMuted: Bool
    let replyDisabled: Bool
    let embeddingDisabled: Bool
    let pinned: Bool

    init(uri: String, cid: String, text: String, author: ProfileViewModel, replyCount: Int, likeCount: Int, repostCount: Int, root: PoastReplyModel?, parent: PoastReplyModel?, embed: PoastPostEmbedModel?, date: Date, repostedBy: ProfileViewModel?, like: String?, repost: String?, threadMuted: Bool, replyDisabled: Bool, embeddingDisabled: Bool, pinned: Bool) {
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
        self.threadMuted = threadMuted
        self.replyDisabled = replyDisabled
        self.embeddingDisabled = embeddingDisabled
        self.pinned = pinned
    }

    init(feedViewPost: Bsky.Feed.FeedViewPost) {
        self.uri = feedViewPost.post.uri
        self.cid = feedViewPost.post.cid

        switch(feedViewPost.post.record) {
        case .post(let post):
            self.text = post.text
        }

        self.author = ProfileViewModel(profileViewBasic: feedViewPost.post.author)
        self.replyCount = feedViewPost.post.replyCount ?? 0
        self.repostCount = feedViewPost.post.repostCount ?? 0
        self.likeCount = feedViewPost.post.likeCount ?? 0

        if let parent = feedViewPost.reply?.parent {
            self.parent = PoastReplyModel(postType: parent)
        } else {
            self.parent = nil
        }

        if let root = feedViewPost.reply?.root {
            self.root = PoastReplyModel(postType: root)
        } else {
            self.root = nil
        }

        if let embed = feedViewPost.post.embed {
            self.embed = PoastPostEmbedModel(embedType: embed)
        } else {
            self.embed = nil
        }

        self.date = feedViewPost.post.indexedAt

        if let reason = feedViewPost.reason {
            switch(reason) {
            case .reasonRepost(let repost):
                self.repostedBy = ProfileViewModel(profileViewBasic: repost.by)
            }
        } else {
            self.repostedBy = nil
        }

        if let viewerState = feedViewPost.post.viewer {
            self.like = viewerState.like
            self.repost = viewerState.repost
            self.threadMuted = viewerState.threadMuted ?? false
            self.replyDisabled = viewerState.replyDisabled ?? false
            self.embeddingDisabled = viewerState.embeddedDisabled ?? false
            self.pinned = viewerState.pinned ?? false
        } else {
            self.like = nil
            self.repost = nil
            self.threadMuted = false
            self.replyDisabled = false
            self.embeddingDisabled = false
            self.pinned = false
        }
    }

    init(postView: Bsky.Feed.PostView) {
        self.uri = postView.uri
        self.cid = postView.cid

        switch(postView.record) {
        case .post(let post):
            self.text = post.text

            if let reply = post.reply {
                self.root = .reference(PoastStrongReferenceModel(atProtoRepoStrongRef: reply.root))
                self.parent = .reference(PoastStrongReferenceModel(atProtoRepoStrongRef: reply.parent))
            } else {
                self.root = nil
                self.parent = nil
            }
        }

        self.author = ProfileViewModel(profileViewBasic: postView.author)
        self.replyCount = postView.replyCount ?? 0
        self.repostCount = postView.repostCount ?? 0
        self.likeCount = postView.likeCount ?? 0
        self.embed = nil
        self.date = postView.indexedAt
        self.repostedBy = nil

        if let viewerState = postView.viewer {
            self.like = viewerState.like
            self.repost = viewerState.repost
            self.threadMuted = viewerState.threadMuted ?? false
            self.replyDisabled = viewerState.replyDisabled ?? false
            self.embeddingDisabled = viewerState.embeddedDisabled ?? false
            self.pinned = viewerState.pinned ?? false
        } else {
            self.like = nil
            self.repost = nil
            self.threadMuted = false
            self.replyDisabled = false
            self.embeddingDisabled = false
            self.pinned = false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
    
    static func ==(lhs: FeedViewPostModel, rhs: FeedViewPostModel) -> Bool {
        return lhs.uri == rhs.uri
    }
}
