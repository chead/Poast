//
//  EmbedExternalExternalModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftATProto
import SwiftBluesky

struct EmbedExternalExternalModel: Hashable {
    let uri: String
    let title: String
    let description: String
    let thumb: BlobModel?

    init(external: Bsky.Embed.External.External) {
        self.uri = external.uri
        self.title = external.title
        self.description = external.description

        if let thumb = external.thumb {
            self.thumb = BlobModel(atProtoBlob: thumb)
        } else {
            self.thumb = nil
        }
    }
}
