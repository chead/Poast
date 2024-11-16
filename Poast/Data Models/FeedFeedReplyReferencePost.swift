//
//  FeedFeedReplyRefPost.swift
//  Poast
//
//  Created by Christopher Head on 1/30/24.
//

import SwiftBluesky

indirect enum FeedFeedReplyReferencePost: Hashable {
    case post(FeedPostViewModel)
    case reference(StrongReferenceModel)
    case notFound(uri: String)
    case blocked(uri: String, authorDid: String)

    init(postType: Bsky.Feed.FeedReplyRef.PostType) {
        switch(postType) {
        case .postView(let postView):
            self = .post(FeedPostViewModel(postView: postView))

        case .notFoundPost(let notFoundPost):
            self = .notFound(uri: notFoundPost.uri)

        case .blockedPost(let blockedPost):
            self = .blocked(uri: blockedPost.uri, authorDid: blockedPost.author.did)
        }
    }
}
