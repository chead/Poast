//
//  PostModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import Foundation
import SwiftBluesky

//public let text: String
//public let facets: [Bsky.Richtext.Facet]?
//public let reply: PostReplyRef?
//public let embed: EmbedType?
//public let langs: [String]?
//public let labels: ATProtoSelfLabels?
//public let tags: [String]?
//public let createdAt: Date

struct PoastPostModel {
    let text: String
//    let embed: PoastPostEmbedModel
    let createdAt: Date

    init(post: Bsky.Feed.Post) {
        self.text = post.text
//        self.embed = PoastPostEmbedModel
        self.createdAt = post.createdAt
    }
}
