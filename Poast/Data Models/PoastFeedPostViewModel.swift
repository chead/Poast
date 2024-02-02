//
//  PoastFeedPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky

struct PoastFeedPostViewModel: Hashable {
    var id: String
    var uri: String
    let text: String
    let author: PoastProfileModel
    let replyCount: Int
    let likeCount: Int
    let repostCount: Int
    let root: PoastReplyReferenceModel?
    let parent: PoastReplyReferenceModel?
    let date: Date

    init(id: String, uri: String, text: String, author: PoastProfileModel, replyCount: Int, likeCount: Int, repostCount: Int, root: PoastReplyReferenceModel?, parent: PoastReplyReferenceModel?, date: Date) {
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

    init(blueSkyFeedPostView: BlueskyFeedPostView) {
        self.id = blueSkyFeedPostView.cid
        self.uri = blueSkyFeedPostView.uri

        switch(blueSkyFeedPostView.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text

            if let reply = blueskyFeedPost.reply {
                self.root = PoastReplyReferenceModel(atProtoRepoStrongRef: reply.root)
                self.parent = PoastReplyReferenceModel(atProtoRepoStrongRef: reply.parent)
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
}
