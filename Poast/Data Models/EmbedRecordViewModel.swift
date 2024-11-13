//
//  EmbedRecordViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftBluesky

enum EmbedRecordViewModel: Hashable {
    case blocked(EmbedRecordViewBlockedModel)
    case notFound(EmbedRecordViewNotFoundModel)
    case record(EmbedRecordViewRecordModel)
    case unknown

    init(view: Bsky.Embed.Record.View) {
        switch(view.record) {
        case .recordViewBlocked(let viewBlocked):
            self = .blocked(EmbedRecordViewBlockedModel(viewBlocked: viewBlocked))

        case .recordViewNotFound(let viewNotFound):
            self = .notFound(EmbedRecordViewNotFoundModel(viewNotFound: viewNotFound))

        case .recordViewRecord(let viewRecord):
            self = .record(EmbedRecordViewRecordModel(viewRecord: viewRecord))

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
