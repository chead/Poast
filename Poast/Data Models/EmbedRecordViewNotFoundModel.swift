//
//  EmbedRecordViewNotFoundModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct EmbedRecordViewNotFoundModel: Hashable {
    let uri: String

    init(viewNotFound: Bsky.Embed.Record.ViewNotFound) {
        self.uri = viewNotFound.uri
    }
}
