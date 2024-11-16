//
//  EmbedExternal.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftBluesky

extension Bsky.Embed.External.ViewExternal: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.External.ViewExternal, rhs: Bsky.Embed.External.ViewExternal) -> Bool {
        return lhs.uri == rhs.uri
    }
}

extension Bsky.Embed.External.ViewExternal: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Embed.External.View: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.External.View, rhs: Bsky.Embed.External.View) -> Bool {
        return lhs.external == rhs.external
    }
}

extension Bsky.Embed.External.View: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(external)
    }
}
