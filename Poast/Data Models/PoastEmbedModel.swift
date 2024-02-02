//
//  PoastEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import Foundation
import SwiftBluesky

struct PoastEmbedImageModel {
    public let fullsize: String
    public let thumb: String
    public let alt: String
    public let aspectRatio: (width: Int, height: Int)?

    init(blueskyEmbedImagesViewImage: BlueskyEmbedImagesViewImage) {
        self.fullsize = blueskyEmbedImagesViewImage.fullsize
        self.thumb = blueskyEmbedImagesViewImage.thumb
        self.alt = blueskyEmbedImagesViewImage.alt

        if let aspectRatio = blueskyEmbedImagesViewImage.aspectRatio {
            self.aspectRatio = (aspectRatio.width, aspectRatio.height)
        } else {
            self.aspectRatio = nil
        }
    }
}

enum PoastEmbedModel {
    case unknown
    case images([PoastEmbedImageModel])

    init(blueskyFeedPostViewEmbedType: BlueskyFeedPostViewEmbedType) {
        switch(blueskyFeedPostViewEmbedType) {
        case .blueskyEmbedImagesView(let blueskyEmbedImagesView):
            self = .images(blueskyEmbedImagesView.images.map { PoastEmbedImageModel(blueskyEmbedImagesViewImage: $0) })

        default:
            self = .unknown
        }
    }
}
