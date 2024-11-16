//
//  EmedRecordWithMedia.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftBluesky

extension Bsky.Embed.RecordWithMedia.View.MediaType: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.RecordWithMedia.View.MediaType, rhs: Bsky.Embed.RecordWithMedia.View.MediaType) -> Bool {
        switch((lhs, rhs)) {
        case (.imagesView(let lhsImagesView),
              .imagesView(let rhsImagesView)):
            return lhsImagesView == rhsImagesView

        case (.externalView(let lhsExternalView),
              .externalView(let rhsExternalView)):
            return lhsExternalView == rhsExternalView

        case (.videoView(let lhsVideoView),
              .videoView(let rhsVideoView)):
            return lhsVideoView == rhsVideoView

        default:
            return false
        }
    }
}

extension Bsky.Embed.RecordWithMedia.View.MediaType: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch(self) {
        case .imagesView(let imagesView):
            hasher.combine(imagesView)

        case .externalView(let externalView):
            hasher.combine(externalView)

        case .videoView(let videoView):
            hasher.combine(videoView)
        }
    }
}

extension Bsky.Embed.RecordWithMedia.View: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.RecordWithMedia.View, rhs: Bsky.Embed.RecordWithMedia.View) -> Bool {
        lhs.record == rhs.record &&
        lhs.media == rhs.media
    }
}

extension Bsky.Embed.RecordWithMedia.View: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(record)
        hasher.combine(media)
    }
}

extension Bsky.Graph.StarterPackViewBasic: @retroactive Equatable {
    public static func ==(lhs: Bsky.Graph.StarterPackViewBasic, rhs: Bsky.Graph.StarterPackViewBasic) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Graph.StarterPackViewBasic: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Labeler.LabelerView: @retroactive Equatable {
    public static func ==(lhs: Bsky.Labeler.LabelerView, rhs: Bsky.Labeler.LabelerView) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Labeler.LabelerView: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Graph.ListView: @retroactive Equatable {
    public static func ==(lhs: Bsky.Graph.ListView, rhs: Bsky.Graph.ListView) -> Bool {
        return lhs.uri == rhs.uri
    }
}

extension Bsky.Graph.ListView: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Feed.GeneratorView: @retroactive Equatable {
    public static func ==(lhs: Bsky.Feed.GeneratorView, rhs: Bsky.Feed.GeneratorView) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Feed.GeneratorView: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}
