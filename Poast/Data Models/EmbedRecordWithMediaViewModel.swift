//
//  EmbedRecordWithMediaViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/13/24.
//

import SwiftBluesky

struct EmbedRecordWithMediaViewModel: Hashable {
    let record: EmbedRecordViewModel
    let media: EmbedRecordWithMediaViewMediaModel

    init(view: Bsky.Embed.RecordWithMedia.View) {
        self.record = EmbedRecordViewModel(view: view.record)
        self.media = EmbedRecordWithMediaViewMediaModel(mediaType: view.media)
    }
}
