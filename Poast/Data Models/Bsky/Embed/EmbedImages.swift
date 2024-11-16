//
//  EmbedImages.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftBluesky

extension Bsky.Embed.Images.ViewImage: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Images.ViewImage, rhs: Bsky.Embed.Images.ViewImage) -> Bool {
        return lhs.fullsize == rhs.fullsize
    }
}

extension Bsky.Embed.Images.ViewImage: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fullsize)
    }
}

extension Bsky.Embed.Images.View: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Images.View, rhs: Bsky.Embed.Images.View) -> Bool {
        return lhs.images == rhs.images
    }
}

extension Bsky.Embed.Images.View: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(images)
    }
}
