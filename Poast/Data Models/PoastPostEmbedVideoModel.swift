//
//  PoastPostEmbedVideoModel.swift
//  Poast
//
//  Created by Christopher Head on 9/22/24.
//

import Foundation
import SwiftBluesky

struct PoastPostEmbedVideoModel: Hashable, Identifiable {
    let id: UUID = UUID()
    let playlist: String
    let thumbnail: String?
    let alt: String?
    let aspectRatio: PoastPostEmbedAspectRatioModel?

    init(playlist: String, thumbnail: String, alt: String, aspectRatio: PoastPostEmbedAspectRatioModel?) {
        self.playlist = playlist
        self.thumbnail = thumbnail
        self.alt = alt
        self.aspectRatio = aspectRatio
    }

    init(blueskyEmbedVideoView: BlueskyEmbedVideoView) {
        self.playlist = blueskyEmbedVideoView.playlist
        self.thumbnail = blueskyEmbedVideoView.thumbnail
        self.alt = blueskyEmbedVideoView.alt

        if let aspectRatio = blueskyEmbedVideoView.aspectRatio {
            self.aspectRatio = PoastPostEmbedAspectRatioModel(blueskyEmbedAspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
