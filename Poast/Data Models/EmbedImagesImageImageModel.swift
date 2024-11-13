//
//  EmbedImagesImageImageModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

enum EmbedImagesImageImageModel: Hashable {
    case blob(BlobModel)
    case imageBlob(ImageBlobModel)

    init(imageType: Bsky.Embed.Images.Image.ImageType) {
        switch(imageType) {
        case .atProtoBlob(let atProtoBlob):
            self = .blob(BlobModel(atProtoBlob: atProtoBlob))

        case .atProtoImageBlob(let atProtoImageBlob):
            self = .imageBlob(ImageBlobModel(atProtoImageBlob: atProtoImageBlob))
        }
    }
}
