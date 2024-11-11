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

    init(threadViewPostPostType: Bsky.Feed.ThreadViewPost.PostType) {

        switch(threadViewPostPostType) {
        case .blockedPost(let blockedPost):
            self = .blocked(PoastBlockedPostModel(uri: blockedPost.uri, authorDid: blockedPost.author.did))

        case .notFoundPost(let notFoundPost):
            self = .notFound(PoastNotFoundPostModel(uri: notFoundPost.uri))

        case .threadViewPost(let threadViewPost):
            self = .threadPost(PoastThreadPostModel(threadViewPost: threadViewPost))
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
