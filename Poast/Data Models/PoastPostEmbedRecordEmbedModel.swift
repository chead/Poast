//
//  PoastPostEmbedRecordEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

struct PoastPostEmbedExternalExternalModel: Hashable {
    let uri: String
    let title: String
    let description: String
    let thumb: PoastBlobModel?

    init(external: Bsky.Embed.External.External) {
        self.uri = external.uri
        self.title = external.title
        self.description = external.description

        if let thumb = external.thumb {
            self.thumb = PoastBlobModel(atProtoBlob: thumb)
        } else {
            self.thumb = nil
        }
    }
}

enum PoastPostEmbedExternalImageImageModel: Hashable {
    case blob(PoastBlobModel)
    case imageBlob(PoastImageBlobModel)

    init(imageType: Bsky.Embed.Images.Image.ImageType) {
        switch(imageType) {
        case .atProtoBlob(let atProtoBlob):
            self = .blob(PoastBlobModel(atProtoBlob: atProtoBlob))

        case .atProtoImageBlob(let atProtoImageBlob):
            self = .imageBlob(PoastImageBlobModel(atProtoImageBlob: atProtoImageBlob))
        }
    }
}

struct PoastPostEmbedExternalImageModel: Hashable {
    let image: PoastPostEmbedExternalImageImageModel
    let alt: String
    let aspectRatio: PoastEmbedImageModelAspectRatio?

    init(image: Bsky.Embed.Images.Image) {
        self.image = PoastPostEmbedExternalImageImageModel(imageType: image.image)
        self.alt = image.alt

        if let aspectRatio = image.aspectRatio {
            self.aspectRatio = PoastEmbedImageModelAspectRatio(aspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}

enum PoastPostEmbedRecordWithMediaMediaModel: Hashable {
    case externalView(PoastPostEmbedExternalModel)
    case imagesView([PoastPostEmbedImageModel])
    case unknown

    init(mediaType: Bsky.Embed.RecordWithMedia.View.MediaType) {

        switch(mediaType) {
        case .externalView(let externalView):
            self = .externalView(PoastPostEmbedExternalModel(viewExternal: externalView.external))

        case .imagesView(let imagesView):
            self = .imagesView(imagesView.images.map { PoastPostEmbedImageModel(viewImage: $0) })

// FIXME: Case
//        case .videoView(_):
//            break

        default:
            self = .unknown
        }
    }
}

struct PoastPostEmbedRecordWithMediaModel: Hashable {
    let record: PoastPostEmbedRecordModel
    let media: PoastPostEmbedRecordWithMediaMediaModel

    init(view: Bsky.Embed.RecordWithMedia.View) {
        self.record = PoastPostEmbedRecordModel(view: view.record)
        self.media = PoastPostEmbedRecordWithMediaMediaModel(mediaType: view.media)
    }
}

enum PoastPostEmbedRecordEmbedModel: Hashable {
    case external(PoastPostEmbedExternalModel)
    case images([PoastPostEmbedImageModel])
    case record(PoastPostEmbedRecordModel)
    case recordWithMedia(PoastPostEmbedRecordWithMediaModel)
    case video(PoastPostEmbedVideoModel)

    init(embedType: Bsky.Embed.Record.ViewRecord.EmbedType) {
        switch(embedType) {
        case .externalView(let externalView):
            self = .external(PoastPostEmbedExternalModel(viewExternal: externalView.external))

        case .imagesView(let imagesView):
            self = .images(imagesView.images.map { PoastPostEmbedImageModel(viewImage: $0) })

        case .recordView(let recordView):
            self = .record(PoastPostEmbedRecordModel(view: recordView))

        case .recordWithMediaView(let recordWithMediaView):
            self = .recordWithMedia(PoastPostEmbedRecordWithMediaModel(view: recordWithMediaView))

        case .videoView(let videoView):
            self = .video(PoastPostEmbedVideoModel(view: videoView))
        }
    }
}
