//
//  EmbedRecordWithMediaView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI
import SwiftBluesky

struct EmbedRecordWithMediaViewView: View {
    let view: Bsky.Embed.RecordWithMedia.View

    var body: some View {
        EmbedRecordViewView(view: view.record)

        switch(view.media) {
        case .imagesView(let view):
            EmbedImagesViewView(view: view)

        case .externalView(let view):
            EmbedExternalViewViewView(view: view)

        case .videoView(let view):
            EmbedVideoViewView(view: view)
        }
    }
}
