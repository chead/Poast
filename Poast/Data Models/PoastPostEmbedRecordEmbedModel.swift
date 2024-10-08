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

    init(blueskyEmbedExternalExternal: BlueskyEmbedExternalExternal) {
        self.uri = blueskyEmbedExternalExternal.uri
        self.title = blueskyEmbedExternalExternal.title
        self.description = blueskyEmbedExternalExternal.description

        if let thumb = blueskyEmbedExternalExternal.thumb {
            self.thumb = PoastBlobModel(atProtoBlob: thumb)
        } else {
            self.thumb = nil
        }
    }
}

enum PoastPostEmbedExternalImageImageModel: Hashable {
    case blob(PoastBlobModel)
    case imageBlob(PoastImageBlobModel)

    init(blueskyEmbedImagesImageType: BlueskyEmbedImagesImageType) {
        switch(blueskyEmbedImagesImageType) {
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

    init(blueskyEmbedImagesImage: BlueskyEmbedImagesImage) {
        self.image = PoastPostEmbedExternalImageImageModel(blueskyEmbedImagesImageType: blueskyEmbedImagesImage.image)
        self.alt = blueskyEmbedImagesImage.alt

        if let aspectRatio = blueskyEmbedImagesImage.aspectRatio {
            self.aspectRatio = PoastEmbedImageModelAspectRatio(blueskyEmbedImagesAspectRatio: aspectRatio)
        } else {
            self.aspectRatio = nil
        }
    }
}

enum PoastPostEmbedRecordWithMediaMediaModel: Hashable {
    case externalView(PoastPostEmbedExternalModel)
    case imagesView([PoastPostEmbedImageModel])
    case unknown

    init(blueskyEmbedRecordWithMediaViewMediaType: BlueskyEmbedRecordWithMediaViewMediaType) {
        switch(blueskyEmbedRecordWithMediaViewMediaType) {
        case .blueskyEmbedExternalView(let blueskyEmbedExternalView):
            self = .externalView(PoastPostEmbedExternalModel(blueskyEmbedExternalViewExternal: blueskyEmbedExternalView.external))

        case .blueskyEmbedImagesView(let blueskyEmbedImagesView):
            self = .imagesView(blueskyEmbedImagesView.images.map { PoastPostEmbedImageModel(blueskyEmbedImagesViewImage: $0) })

        case .unknown:
            self = .unknown
        }
    }
}

struct PoastPostEmbedRecordWithMediaModel: Hashable {
    let record: PoastPostEmbedRecordModel
    let media: PoastPostEmbedRecordWithMediaMediaModel

    init(blueskyEmbedRecordWithMediaView: BlueskyEmbedRecordWithMediaView) {
        self.record = PoastPostEmbedRecordModel(blueskyEmbedRecordView: blueskyEmbedRecordWithMediaView.record)
        self.media = PoastPostEmbedRecordWithMediaMediaModel(blueskyEmbedRecordWithMediaViewMediaType: blueskyEmbedRecordWithMediaView.media)
    }
}

enum PoastPostEmbedRecordEmbedModel: Hashable {
    case external(PoastPostEmbedExternalModel)
    case images([PoastPostEmbedImageModel])
    case record(PoastPostEmbedRecordModel)
    case recordWithMedia(PoastPostEmbedRecordWithMediaModel)
    case video(PoastPostEmbedVideoModel)

    init(blueskyEmbedRecordViewRecordEmbedType: BlueskyEmbedRecordViewRecordEmbedType) {
        switch(blueskyEmbedRecordViewRecordEmbedType) {
        case .blueskyEmbedExternalView(let blueskyEmbedExternalView):
            self = .external(PoastPostEmbedExternalModel(blueskyEmbedExternalViewExternal: blueskyEmbedExternalView.external))

        case .blueskyEmbedImagesView(let blueskyEmbedImagesView):
            self = .images(blueskyEmbedImagesView.images.map { PoastPostEmbedImageModel(blueskyEmbedImagesViewImage: $0) })

        case .blueskyEmbedRecordView(let blueskyEmbedRecordView):
            self = .record(PoastPostEmbedRecordModel(blueskyEmbedRecordView: blueskyEmbedRecordView))

        case .blueskyEmbedRecordWithMediaView(let blueskyEmbedRecordWithMediaView):
            self = .recordWithMedia(PoastPostEmbedRecordWithMediaModel(blueskyEmbedRecordWithMediaView: blueskyEmbedRecordWithMediaView))

        case .blueskyEmbedVideoView(let blueskyEmbedVideoView):
            self = .video(PoastPostEmbedVideoModel(blueskyEmbedVideoView: blueskyEmbedVideoView))
        }
    }
}
