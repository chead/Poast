//
//  PoastPostEmbedExternalModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky

struct PoastPostEmbedExternalModel: Hashable {
    let uri: String
    let description: String
    let thumb: String?

    init(uri: String, description: String, thumb: String?) {
        self.uri = uri
        self.description = description
        self.thumb = thumb
    }

    init(blueskyEmbedExternalViewExternal: BlueskyEmbedExternalViewExternal) {
        self.uri = blueskyEmbedExternalViewExternal.uri
        self.description = blueskyEmbedExternalViewExternal.description
        self.thumb = blueskyEmbedExternalViewExternal.thumb
    }
}
