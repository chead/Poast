//
//  PoastReplyModel.swift
//  Poast
//
//  Created by Christopher Head on 1/30/24.
//

import Foundation
import SwiftBluesky

indirect enum PoastReplyModel: Hashable {
    case post(PoastVisiblePostModel)
    case reference(PoastStrongReferenceModel)
    case notFound(uri: String)
    case blocked(uri: String, authorDid: String)

    init(postType: Bsky.Feed.FeedReplyRef.PostType) {
        switch(postType) {
        case .postView(let postView):
            self = .post(PoastVisiblePostModel(postView: postView))

        case .notFoundPost(let notFoundPost):
            self = .notFound(uri: notFoundPost.uri)

        case .blockedPost(let blockedPost):
            self = .blocked(uri: blockedPost.uri, authorDid: blockedPost.author.did)
        }
    }
}
