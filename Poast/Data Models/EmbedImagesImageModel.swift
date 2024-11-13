//
//  EmbedImagesImageModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct EmbedImagesImageModel: Hashable {
    let image: EmbedImagesImageImageModel
    let alt: String
    let aspectRatio: EmbedImagesViewImageAspectRatio?

    init(image: Bsky.Embed.Images.Image) {
        self.image = EmbedImagesImageImageModel(imageType: image.image)
        self.alt = image.alt

        if let aspectRatio = image.aspectRatio {
            self.aspectRatio = EmbedImagesViewImageAspectRatio(aspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}
