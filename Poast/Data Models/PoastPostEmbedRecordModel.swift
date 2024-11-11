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

    init(viewBlocked: Bsky.Embed.Record.ViewBlocked) {
        self.uri = viewBlocked.uri
        self.profile = PoastBlockedProfileModel(blockedAuthor: viewBlocked.author)
    }
}

struct PoastPostEmbedNotFoundRecordModel: Hashable {
    let uri: String

    init(viewNotFound: Bsky.Embed.Record.ViewNotFound) {
        self.uri = viewNotFound.uri
    }
}

struct PoastPostEmbedRecordRecordModel: Hashable {
    let uri: String
    let cid: String
    let author: PoastProfileModel
    let labels: [PoastLabelModel]?
    let embeds: [PoastPostEmbedRecordEmbedModel]?
    let indexedAt: Date

    init(viewRecord: Bsky.Embed.Record.ViewRecord) {
        self.uri = viewRecord.uri
        self.cid = viewRecord.cid
        self.author = PoastProfileModel(profileViewBasic: viewRecord.author)
        self.labels = viewRecord.labels?.map { PoastLabelModel(atProtoLabel: $0) }
        self.embeds = viewRecord.embeds?.map { PoastPostEmbedRecordEmbedModel(embedType: $0) }
        self.indexedAt = viewRecord.indexedAt
    }
}

enum PoastPostEmbedRecordModel: Hashable {
    case blocked(PoastPostEmbedBlockedRecordModel)
    case notFound(PoastPostEmbedNotFoundRecordModel)
    case record(PoastPostEmbedRecordRecordModel)
    case unknown

    init(view: Bsky.Embed.Record.View) {
        switch(view.record) {
        case .recordViewBlocked(let viewBlocked):
            self = .blocked(PoastPostEmbedBlockedRecordModel(viewBlocked: viewBlocked))

        case .recordViewNotFound(let viewNotFound):
            self = .notFound(PoastPostEmbedNotFoundRecordModel(viewNotFound: viewNotFound))

        case .recordViewRecord(let viewRecord):
            self = .record(PoastPostEmbedRecordRecordModel(viewRecord: viewRecord))

// FIXME: Cases
//        case .feedGeneratorView(_):
//            break
//        case .graphListView(_):
//            break

        default:
            self = .unknown
        }
    }
}
