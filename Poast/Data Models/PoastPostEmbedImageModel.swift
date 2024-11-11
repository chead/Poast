//
//  PoastPostEmbedImageModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky

struct PoastEmbedImageModelAspectRatio: Hashable {
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

struct PoastPostEmbedImageModel: Hashable {
    let fullsize: String
    let thumb: String
    let alt: String
    let aspectRatio: PoastEmbedImageModelAspectRatio?

    init(fullsize: String, thumb: String, alt: String, aspectRatio: PoastEmbedImageModelAspectRatio?) {
        self.fullsize = fullsize
        self.thumb = thumb
        self.alt = alt
        self.aspectRatio = aspectRatio
    }

    init(viewImage: Bsky.Embed.Images.ViewImage) {
        self.fullsize = viewImage.fullsize
        self.thumb = viewImage.thumb
        self.alt = viewImage.alt

        if let aspectRatio = viewImage.aspectRatio {
            self.aspectRatio = PoastEmbedImageModelAspectRatio(aspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
