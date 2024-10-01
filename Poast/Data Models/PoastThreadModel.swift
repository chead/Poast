//
//  PoastThreadModel.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import Foundation
import SwiftBluesky


indirect enum PoastThreadModel: Hashable, Identifiable {
    var id: Self { self }

    case threadPost(PoastThreadPostModel)
    case notFound(PoastNotFoundPostModel)
    case blocked(PoastBlockedPostModel)

    init(blueskyFeedThreadViewPostPostType: BlueskyFeedThreadViewPostPostType) {
        switch(blueskyFeedThreadViewPostPostType) {
        case .blueskyFeedThreadViewPost(let blueskyFeedThreadViewPost):
            self = .threadPost(PoastThreadPostModel(blueskyFeedThreadViewPost: blueskyFeedThreadViewPost))

        case .blueskyFeedNotFoundPost(let blueskyFeedNotFoundPost):
            self = .notFound(PoastNotFoundPostModel(uri: blueskyFeedNotFoundPost.uri))

        case .blueskyFeedBlockedPost(let blueskyFeedBlockedPost):
            self = .blocked(PoastBlockedPostModel(uri: blueskyFeedBlockedPost.uri, authorDid: blueskyFeedBlockedPost.author.did))
        }
    }
}
