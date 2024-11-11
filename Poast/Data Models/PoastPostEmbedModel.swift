//
//  PoastPostEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import Foundation
import SwiftBluesky

enum PoastPostEmbedModel {
    case images([PoastPostEmbedImageModel])
    case external(PoastPostEmbedExternalModel)
    case record(PoastPostEmbedRecordModel)
    case recordWithMedia(PoastPostEmbedRecordWithMediaModel)
    case video(PoastPostEmbedVideoModel)

    init(embedType: Bsky.Feed.PostView.EmbedType) {
        switch(embedType) {
        case .imagesView(let ImagesView):
            self = .images(ImagesView.images.map { PoastPostEmbedImageModel(viewImage: $0) })

        case .externalView(let externalView):
            self = .external(PoastPostEmbedExternalModel(viewExternal: externalView.external))

        case .recordView(let recordView):
            self = .record(PoastPostEmbedRecordModel(view: recordView))

        case .recordWithMediaView(let recordWithMediaView):
            self = .recordWithMedia(PoastPostEmbedRecordWithMediaModel(view: recordWithMediaView))

        case .videoView(let videoView):
            self = .video(PoastPostEmbedVideoModel(view: videoView))
        }
    }
}
