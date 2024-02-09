//
//  PoastMutablePost.swift
//  Poast
//
//  Created by Christopher Head on 2/9/24.
//

import Foundation

class PoastMutablePost {
    var id: UUID
    var uri: String
    var cid: String
    var text: String
    var author: PoastProfileModel
    var replyCount: Int
    var likeCount: Int
    var repostCount: Int
    var root: PoastReplyModel?
    var parent: PoastReplyModel?
    var embed: PoastPostEmbedModel?
    var date: Date
    var repostedBy: PoastProfileModel?
    var like: String?
    var repost: String?
    var replyDisabled: Bool

    init(postModel: PoastPostModel) {
        self.id = postModel.id
        self.uri = postModel.uri
        self.cid = postModel.cid
        self.text = postModel.text
        self.author = postModel.author
        self.replyCount = postModel.replyCount
        self.likeCount = postModel.likeCount
        self.repostCount = postModel.repostCount
        self.root = postModel.root
        self.parent = postModel.parent
        self.embed = postModel.embed
        self.date = postModel.date
        self.repostedBy = postModel.repostedBy
        self.like = postModel.like
        self.repost = postModel.repost
        self.replyDisabled = postModel.replyDisabled
    }

    var immutableCopy: PoastPostModel {
        return PoastPostModel(id: self.id,
                              uri: self.uri,
                              cid: self.cid,
                              text: self.text,
                              author: self.author,
                              replyCount: self.replyCount,
                              likeCount: self.likeCount,
                              repostCount: self.repostCount,
                              root: self.root,
                              parent: self.parent,
                              embed: self.embed,
                              date: self.date,
                              repostedBy: self.repostedBy,
                              like: self.like,
                              repost: self.repost,
                              replyDisabled: self.replyDisabled)
    }
}
