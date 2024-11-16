//
//  FeedViewPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct FeedFeedViewPostModel: Hashable, Identifiable {
    let id = UUID()
    let uri: String
    let cid: String
    let text: String
    let author: ActorProfileViewModel
    let replyCount: Int
    let likeCount: Int
    let repostCount: Int
    let root: FeedFeedReplyReferencePost?
    let parent: FeedFeedReplyReferencePost?
    let embed: FeedPostViewEmbedModel?
    let date: Date
    let repostedBy: ActorProfileViewModel?
    let viewer: FeedViewerStateModel?

//    init(uri: String, cid: String, text: String, author: ActorProfileViewModel, replyCount: Int, likeCount: Int, repostCount: Int, root: FeedFeedReplyRefPost?, parent: FeedFeedReplyRefPost?, embed: FeedPostViewEmbedModel?, date: Date, repostedBy: ActorProfileViewModel?, like: String?, repost: String?, threadMuted: Bool, replyDisabled: Bool, embeddingDisabled: Bool, pinned: Bool) {
//        self.uri = uri
//        self.cid = cid
//        self.text = text
//        self.author = author
//        self.replyCount = replyCount
//        self.likeCount = likeCount
//        self.repostCount = repostCount
//        self.root = root
//        self.parent = parent
//        self.embed = embed
//        self.date = date
//        self.repostedBy = repostedBy
//        self.like = like
//        self.repost = repost
//        self.threadMuted = threadMuted
//        self.replyDisabled = replyDisabled
//        self.embeddingDisabled = embeddingDisabled
//        self.pinned = pinned
//    }

    init(feedViewPost: Bsky.Feed.FeedViewPost) {
        self.uri = feedViewPost.post.uri
        self.cid = feedViewPost.post.cid

        switch(feedViewPost.post.record) {
        case .post(let post):
            self.text = post.text
        }

        self.author = ActorProfileViewModel(profileViewBasic: feedViewPost.post.author)
        self.replyCount = feedViewPost.post.replyCount ?? 0
        self.repostCount = feedViewPost.post.repostCount ?? 0
        self.likeCount = feedViewPost.post.likeCount ?? 0

        if let parent = feedViewPost.reply?.parent {
            self.parent = FeedFeedReplyReferencePost(postType: parent)
        } else {
            self.parent = nil
        }

        if let root = feedViewPost.reply?.root {
            self.root = FeedFeedReplyReferencePost(postType: root)
        } else {
            self.root = nil
        }

        if let embed = feedViewPost.post.embed {
            self.embed = FeedPostViewEmbedModel(embedType: embed)
        } else {
            self.embed = nil
        }

        self.date = feedViewPost.post.indexedAt

        if let reason = feedViewPost.reason {
            switch(reason) {
            case .reasonRepost(let repost):
                self.repostedBy = ActorProfileViewModel(profileViewBasic: repost.by)
            }
        } else {
            self.repostedBy = nil
        }

        if let viewerState = feedViewPost.post.viewer {
            self.viewer = FeedViewerStateModel(viewerState: viewerState)
        } else {
            self.viewer = nil
        }
//        if let viewerState = feedViewPost.post.viewer {
//            self.like = viewerState.like
//            self.repost = viewerState.repost
//            self.threadMuted = viewerState.threadMuted ?? false
//            self.replyDisabled = viewerState.replyDisabled ?? false
//            self.embeddingDisabled = viewerState.embeddedDisabled ?? false
//            self.pinned = viewerState.pinned ?? false
//        } else {
//            self.like = nil
//            self.repost = nil
//            self.threadMuted = false
//            self.replyDisabled = false
//            self.embeddingDisabled = false
//            self.pinned = false
//        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
    
    static func ==(lhs: FeedFeedViewPostModel, rhs: FeedFeedViewPostModel) -> Bool {
        return lhs.uri == rhs.uri
    }
}
