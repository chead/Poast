//
//  EmbedVideoViewModel.swift
//  Poast
//
//  Created by Christopher Head on 9/22/24.
//

import SwiftBluesky

struct EmbedVideoViewModel: Hashable {
    let playlist: String
    let thumbnail: String?
    let alt: String?
    let aspectRatio: EmbedAspectRatioModel?

    init(playlist: String, thumbnail: String, alt: String, aspectRatio: EmbedAspectRatioModel?) {
        self.playlist = playlist
        self.thumbnail = thumbnail
        self.alt = alt
        self.aspectRatio = aspectRatio
    }

    init(view: Bsky.Embed.Video.View) {
        self.playlist = view.playlist
        self.thumbnail = view.thumbnail
        self.alt = view.alt

        if let aspectRatio = view.aspectRatio {
            self.aspectRatio = EmbedAspectRatioModel(aspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
