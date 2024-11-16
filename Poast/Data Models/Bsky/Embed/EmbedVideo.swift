//
//  EmbedVide0.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftBluesky

extension Bsky.Embed.Video.View: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Video.View, rhs: Bsky.Embed.Video.View) -> Bool {
        lhs.cid == rhs.cid
    }
}

extension Bsky.Embed.Video.View: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
}
