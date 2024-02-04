//
//  PoastPostEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import Foundation
import SwiftBluesky

//struct PoastFeedViewerState {
//    let repost: String?
//    let like: String?
//    let replyDisabled: Bool?
//
//    init(blueskyFeedViewerState: BlueskyFeedViewerState) {
//        self.repost = blueskyFeedViewerState.repost
//        self.like = blueskyFeedViewerState.like
//        self.replyDisabled = blueskyFeedViewerState.replyDisabled
//    }
//}

enum PoastPostEmbedModel: Hashable {
    case unknown
    case images([PoastPostEmbedImageModel])
    case externalView(PoastPostEmbedExternalModel)
    case record(PoastPostEmbedRecordModel)

    init(blueskyFeedPostViewEmbedType: BlueskyFeedPostViewEmbedType) {
        switch(blueskyFeedPostViewEmbedType) {
        case .blueskyEmbedImagesView(let blueskyEmbedImagesView):
            self = .images(blueskyEmbedImagesView.images.map { PoastPostEmbedImageModel(blueskyEmbedImagesViewImage: $0) })

        case .blueskyEmbedExternalView(let blueskyEmbedExternalView):
            self = .externalView(PoastPostEmbedExternalModel(blueskyEmbedExternalViewExternal: blueskyEmbedExternalView.external))

        case .blueskyEmbedRecordView(let blueskyEmbedRecordView):
            self = .record(PoastPostEmbedRecordModel(blueskyEmbedRecordViewRecordType: blueskyEmbedRecordView.record))

        default:
            self = .unknown
        }
    }
}
