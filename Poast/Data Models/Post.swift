//
//  PoastPost.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastPost: Hashable, Equatable, Identifiable {
    var id: String
    let text: String
    let author: User

    init(id: String, text: String, author: User) {
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

        self.author = User(blueskyActorViewBasic: blueskyFeedFeedViewPost.post.author)
    }
}
