//
//  FeedViewerStateModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct FeedViewerStateModel {
    let repost: String?
    let like: String?
    let threadMuted: Bool?
    let replyDisabled: Bool?
    let embeddedDisabled: Bool?
    let pinned: Bool?

    init(viewerState: Bsky.Feed.ViewerState) {
        self.repost = viewerState.repost
        self.like = viewerState.like
        self.threadMuted = viewerState.threadMuted
        self.replyDisabled = viewerState.replyDisabled
        self.embeddedDisabled = viewerState.embeddedDisabled
        self.pinned = viewerState.pinned
    }
}
