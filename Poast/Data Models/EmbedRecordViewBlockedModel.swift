//
//  EmbedRecordViewBlockedModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct EmbedRecordViewBlockedModel: Hashable {
    let uri: String
    let profile: FeedBlockedAuthorModel

    init(viewBlocked: Bsky.Embed.Record.ViewBlocked) {
        self.uri = viewBlocked.uri
        self.profile = FeedBlockedAuthorModel(blockedAuthor: viewBlocked.author)
    }
}
