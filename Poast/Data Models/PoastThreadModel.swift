//
//  PoastThreadModel.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import Foundation
import SwiftBluesky

indirect enum PoastThreadModel: Hashable, Identifiable {
    var id: Self { return self }

    case blocked(PoastBlockedPostModel)
    case notFound(PoastNotFoundPostModel)
    case threadPost(PoastThreadPostModel)

    init(blueskyFeedThreadViewPostPostType: BlueskyFeedThreadViewPostPostType) {
        switch(blueskyFeedThreadViewPostPostType) {

        case .blueskyFeedBlockedPost(let blueskyFeedBlockedPost):
            self = .blocked(PoastBlockedPostModel(uri: blueskyFeedBlockedPost.uri, authorDid: blueskyFeedBlockedPost.author.did))

        case .blueskyFeedNotFoundPost(let blueskyFeedNotFoundPost):
            self = .notFound(PoastNotFoundPostModel(uri: blueskyFeedNotFoundPost.uri))

        case .blueskyFeedThreadViewPost(let blueskyFeedThreadViewPost):
            self = .threadPost(PoastThreadPostModel(blueskyFeedThreadViewPost: blueskyFeedThreadViewPost))
        }
    }

    static func ==(lhs: PoastThreadModel, rhs: PoastThreadModel) -> Bool {
        switch(lhs, rhs) {
        case (.blocked(let lhsValue), .blocked(let rhsValue)):
            return lhsValue == rhsValue

        case (.notFound(let lhsValue), .notFound(let rhsValue)):
            return lhsValue == rhsValue

        case (.threadPost(let lhsValue), .threadPost(let rhsValue)):
            return lhsValue == rhsValue

        default:
            return false
        }
    }
}
