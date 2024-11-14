//
//  EmbedRecordViewRecordEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import SwiftBluesky

enum EmbedRecordViewRecordEmbedModel: Hashable, Identifiable {
    var id: Self { return self}

    case external(EmbedExternalViewExternalModel)
    case images([EmbedImagesViewImageModel])
    case record(EmbedRecordViewModel)
    case recordWithMedia(EmbedRecordWithMediaViewModel)
    case video(EmbedVideoViewModel)

    init(embedType: Bsky.Embed.Record.ViewRecord.EmbedType) {
        switch(embedType) {
        case .externalView(let externalView):
            self = .external(EmbedExternalViewExternalModel(viewExternal: externalView.external))

        case .imagesView(let imagesView):
            self = .images(imagesView.images.map { EmbedImagesViewImageModel(viewImage: $0) })

        case .recordView(let recordView):
            self = .record(EmbedRecordViewModel(view: recordView))

        case .recordWithMediaView(let recordWithMediaView):
            self = .recordWithMedia(EmbedRecordWithMediaViewModel(view: recordWithMediaView))

        case .videoView(let videoView):
            self = .video(EmbedVideoViewModel(view: videoView))
        }
    }
}
