//
//  EmbedImagesViewImageAspectRatio.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct EmbedImagesViewImageAspectRatio: Hashable {
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init(aspectRatio: Bsky.Embed.AspectRatio) {
        self.width = aspectRatio.width
        self.height = aspectRatio.height
    }
}
