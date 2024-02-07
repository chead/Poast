//
//  PoastPostEmbedRecordModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

struct PoastPostEmbedBlockedRecordModel: Hashable {
    let uri: String
    let profile: PoastBlockedProfileModel

    init(blueskyEmbedRecordViewBlocked: BlueskyEmbedRecordViewBlocked) {
        self.uri = blueskyEmbedRecordViewBlocked.uri
        self.profile = PoastBlockedProfileModel(blueskyFeedBlockedAuthor: blueskyEmbedRecordViewBlocked.author)
    }
}

struct PoastPostEmbedNotFoundRecordModel: Hashable {
    let uri: String

    init(blueskyEmbedRecordViewNotFound: BlueskyEmbedRecordViewNotFound) {
        self.uri = blueskyEmbedRecordViewNotFound.uri
    }
}

struct PoastPostEmbedRecordRecordModel: Hashable {
    let uri: String
    let cid: String
    let author: PoastProfileModel
    let labels: [PoastLabelModel]?
    let embeds: [PoastPostEmbedRecordEmbedModel]?
    let indexedAt: Date

    init(blueskyEmbedRecordViewRecord: BlueskyEmbedRecordViewRecord) {
        self.uri = blueskyEmbedRecordViewRecord.uri
        self.cid = blueskyEmbedRecordViewRecord.cid
        self.author = PoastProfileModel(blueskyActorProfileViewBasic: blueskyEmbedRecordViewRecord.author)
        self.labels = blueskyEmbedRecordViewRecord.labels?.map { PoastLabelModel(atProtoLabel: $0) }
        self.embeds = blueskyEmbedRecordViewRecord.embeds?.map { PoastPostEmbedRecordEmbedModel(blueskyEmbedRecordViewRecordEmbedType: $0) }
        self.indexedAt = blueskyEmbedRecordViewRecord.indexedAt
    }
}

enum PoastPostEmbedRecordModel: Hashable {
    case unknown
    case blocked(PoastPostEmbedBlockedRecordModel)
    case notFound(PoastPostEmbedNotFoundRecordModel)
    case record(PoastPostEmbedRecordRecordModel)

    init(blueskyEmbedRecordView: BlueskyEmbedRecordView) {
        switch(blueskyEmbedRecordView.record) {
        case .blueskyEmbedRecordViewBlocked(let blueskyEmbedRecordViewBlocked):
            self = .blocked(PoastPostEmbedBlockedRecordModel(blueskyEmbedRecordViewBlocked: blueskyEmbedRecordViewBlocked))

        case .blueskyEmbedRecordViewNotFound(let blueskyEmbedRecordViewNotFound):
            self = .notFound(PoastPostEmbedNotFoundRecordModel(blueskyEmbedRecordViewNotFound: blueskyEmbedRecordViewNotFound))

        case .blueskyEmbedRecordViewRecord(let blueskyEmbedRecordViewRecord):
            self = .record(PoastPostEmbedRecordRecordModel(blueskyEmbedRecordViewRecord: blueskyEmbedRecordViewRecord))

        default:
            self = .unknown
        }
    }
}
