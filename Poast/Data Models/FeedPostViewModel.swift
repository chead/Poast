//
//  FeedFeedPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import Foundation
import SwiftBluesky

//struct FeedPostModel {
//    let text: String
//    let facets: [Bsky.Richtext.Facet]?
//    let reply: PostReplyRef?
//    let embed: EmbedType?
//    let langs: [String]?
//    let labels: ATProtoSelfLabels?
//    let tags: [String]?
//    let createdAt: Date
//}

struct FeedPostViewModel: Hashable, Identifiable {
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
    let date: Date
    let like: String?
    let repost: String?
    let threadMuted: Bool
    let replyDisabled: Bool
    let embeddingDisabled: Bool
    let pinned: Bool

    init(postView: Bsky.Feed.PostView) {
        self.uri = postView.uri
        self.cid = postView.cid

        switch(postView.record) {
        case .post(let post):
            self.text = post.text

            if let reply = post.reply {
                self.root = .reference(StrongReferenceModel(atProtoRepoStrongRef: reply.root))
                self.parent = .reference(StrongReferenceModel(atProtoRepoStrongRef: reply.parent))
            } else {
                self.root = nil
                self.parent = nil
            }
        }

        self.author = ActorProfileViewModel(profileViewBasic: postView.author)
        self.replyCount = postView.replyCount ?? 0
        self.repostCount = postView.repostCount ?? 0
        self.likeCount = postView.likeCount ?? 0
        self.date = postView.indexedAt

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

    static func ==(lhs: FeedPostViewModel, rhs: FeedPostViewModel) -> Bool {
        return lhs.uri == rhs.uri
    }
}
