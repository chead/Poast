//
//  EmbedRecordViewRecordModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import Foundation
import SwiftBluesky

struct EmbedRecordViewRecordModel: Hashable {
    let uri: String
    let cid: String
    let author: ActorProfileViewModel
    let labels: [LabelModel]?
    let embeds: [EmbedRecordViewRecordEmbedModel]?
    let indexedAt: Date


    init(viewRecord: Bsky.Embed.Record.ViewRecord) {
        self.uri = viewRecord.uri
        self.cid = viewRecord.cid
        self.author = ActorProfileViewModel(profileViewBasic: viewRecord.author)
        self.labels = viewRecord.labels?.map { LabelModel(atProtoLabel: $0) }
        self.embeds = viewRecord.embeds?.map { EmbedRecordViewRecordEmbedModel(embedType: $0) }
        self.indexedAt = viewRecord.indexedAt
    }
}
