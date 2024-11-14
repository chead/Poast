//
//  FeedBlockedAuthorModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftBluesky

struct FeedBlockedAuthorModel: Hashable {
    let did: String

    init(blockedAuthor: Bsky.Feed.BlockedAuthor) {
        self.did = blockedAuthor.did
    }
}
