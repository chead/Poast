//
//  EmbedRecordWithMediaViewMediaModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

enum EmbedRecordWithMediaViewMediaModel: Hashable {
    case externalView(EmbedExternalViewExternalModel)
    case imagesView([EmbedImagesViewImageModel])
    case unknown

    init(mediaType: Bsky.Embed.RecordWithMedia.View.MediaType) {

        switch(mediaType) {
        case .externalView(let externalView):
            self = .externalView(EmbedExternalViewExternalModel(viewExternal: externalView.external))

        case .imagesView(let imagesView):
            self = .imagesView(imagesView.images.map { EmbedImagesViewImageModel(viewImage: $0) })

// FIXME: Case
//        case .videoView(_):
//            break

        default:
            self = .unknown
        }
    }
}
