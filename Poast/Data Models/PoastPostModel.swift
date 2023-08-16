//
//  PoastPostModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastPostModel: Hashable, Equatable, Identifiable {
    var id: String
    let text: String
    let author: PoastUserModel

    init(id: String, text: String, author: PoastUserModel) {
        self.id = id
        self.text = text
        self.author = author
    }
    
    init(blueskyFeedFeedViewPost: BlueskyFeedFeedViewPost) {
        self.id = blueskyFeedFeedViewPost.post.cid

        switch(blueskyFeedFeedViewPost.post.record) {
        case .blueskyFeedPost(let blueskyFeedPost):
            self.text = blueskyFeedPost.text
        }

        self.author = PoastUserModel(blueskyActorViewBasic: blueskyFeedFeedViewPost.post.author)
    }
}
