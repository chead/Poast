//
//  PoastPostEmbedExternalModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftBluesky

struct EmbedExternalViewExternalModel: Hashable {
    let uri: String
    let description: String
    let thumb: String?

    init(uri: String, description: String, thumb: String?) {
        self.uri = uri
        self.description = description
        self.thumb = thumb
    }

    init(viewExternal: Bsky.Embed.External.ViewExternal) {
        self.uri = viewExternal.uri
        self.description = viewExternal.description
        self.thumb = viewExternal.thumb
    }
}
