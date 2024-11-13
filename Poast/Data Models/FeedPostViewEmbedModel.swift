//
//  FeedPostViewEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import SwiftBluesky

enum FeedPostViewEmbedModel {
    case images([EmbedImagesViewImageModel])
    case external(EmbedExternalViewExternalModel)
    case record(EmbedRecordViewModel)
    case recordWithMedia(EmbedRecordWithMediaViewModel)
    case video(EmbedVideoViewModel)

    init(embedType: Bsky.Feed.PostView.EmbedType) {
        switch(embedType) {
        case .imagesView(let imagesView):
            self = .images(imagesView.images.map { EmbedImagesViewImageModel(viewImage: $0) })

        case .externalView(let externalView):
            self = .external(EmbedExternalViewExternalModel(viewExternal: externalView.external))

        case .recordView(let recordView):
            self = .record(EmbedRecordViewModel(view: recordView))

        case .recordWithMediaView(let recordWithMediaView):
            self = .recordWithMedia(EmbedRecordWithMediaViewModel(view: recordWithMediaView))

        case .videoView(let videoView):
            self = .video(EmbedVideoViewModel(view: videoView))
        }
    }
}
