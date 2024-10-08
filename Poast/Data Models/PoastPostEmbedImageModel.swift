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

    init(blueskyEmbedImagesAspectRatio: BlueskyEmbedImagesAspectRatio) {
        self.width = blueskyEmbedImagesAspectRatio.width
        self.height = blueskyEmbedImagesAspectRatio.height
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

    init(blueskyEmbedImagesViewImage: BlueskyEmbedImagesViewImage) {
        self.fullsize = blueskyEmbedImagesViewImage.fullsize
        self.thumb = blueskyEmbedImagesViewImage.thumb
        self.alt = blueskyEmbedImagesViewImage.alt

        if let aspectRatio = blueskyEmbedImagesViewImage.aspectRatio {
            self.aspectRatio = PoastEmbedImageModelAspectRatio(blueskyEmbedImagesAspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
