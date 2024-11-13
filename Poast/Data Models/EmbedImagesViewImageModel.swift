//
//  EmbedImagesViewImage.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky

struct EmbedImagesViewImageModel: Hashable {
    let fullsize: String
    let thumb: String
    let alt: String
    let aspectRatio: EmbedImagesViewImageAspectRatio?

    init(fullsize: String, thumb: String, alt: String, aspectRatio: EmbedImagesViewImageAspectRatio?) {
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
            self.aspectRatio = EmbedImagesViewImageAspectRatio(aspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
