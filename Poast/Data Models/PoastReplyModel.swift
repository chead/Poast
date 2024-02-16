//
//  PoastReplyModel.swift
//  Poast
//
//  Created by Christopher Head on 1/30/24.
//

import Foundation
import SwiftBluesky

indirect enum PoastReplyModel: Hashable {
    case post(PoastPostModel)
    case reference(PoastStrongReferenceModel)
    case notFound(uri: String)
    case blocked(uri: String, authorDid: String)

    init(blueskyFeedReplyRefPostType: BlueskyFeedReplyRefPostType) {
        switch(blueskyFeedReplyRefPostType) {
        case .blueskyFeedPostView(let blueskyFeedPostView):
            self = .post(PoastPostModel(blueskyFeedPostView: blueskyFeedPostView))

        case .blueskyFeedNotFoundPost(let blueskyFeedNotFoundPost):
            self = .notFound(uri: blueskyFeedNotFoundPost.uri)

        case .blueskyFeedBlockedPost(let blueskyFeedBlockedPost):
            self = .blocked(uri: blueskyFeedBlockedPost.uri, authorDid: blueskyFeedBlockedPost.author.did)
        }
    }
}
