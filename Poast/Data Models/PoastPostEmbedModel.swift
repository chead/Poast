//
//  PoastPostEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import Foundation
import SwiftBluesky

enum PoastPostEmbedModel: Hashable {
    case images([PoastPostEmbedImageModel])
    case external(PoastPostEmbedExternalModel)
    case record(PoastPostEmbedRecordModel)
    case recordWithMedia(PoastPostEmbedRecordWithMediaModel)
    case video(PoastPostEmbedVideoModel)

    init(blueskyFeedPostViewEmbedType: BlueskyFeedPostViewEmbedType) {
        switch(blueskyFeedPostViewEmbedType) {
        case .blueskyEmbedImagesView(let blueskyEmbedImagesView):
            self = .images(blueskyEmbedImagesView.images.map { PoastPostEmbedImageModel(blueskyEmbedImagesViewImage: $0) })

        case .blueskyEmbedExternalView(let blueskyEmbedExternalView):
            self = .external(PoastPostEmbedExternalModel(blueskyEmbedExternalViewExternal: blueskyEmbedExternalView.external))

        case .blueskyEmbedRecordView(let blueskyEmbedRecordView):
            self = .record(PoastPostEmbedRecordModel(blueskyEmbedRecordView: blueskyEmbedRecordView))

        case .blueskyEmbedRecordWithMediaView(let blueskyEmbedRecordWithMediaView):
            self = .recordWithMedia(PoastPostEmbedRecordWithMediaModel(blueskyEmbedRecordWithMediaView: blueskyEmbedRecordWithMediaView))

        case .blueskyEmbedVideoView(let blueskyEmbedVideoView):
            self = .video(PoastPostEmbedVideoModel(blueskyEmbedVideoView: blueskyEmbedVideoView))
        }
    }
}
