//
//  EmbedRecordViewView.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftUI
import SwiftBluesky

struct EmbedRecordViewView: View {
    @EnvironmentObject var user: UserModel

    let view: Bsky.Embed.Record.View

    var body: some View {
        switch(view.record) {
        case .recordViewRecord(let viewRecord):
            VStack {
                HStack {
                    AvatarView(size: .small,
                               url: URL(string: viewRecord.author.avatar ?? ""))

                    Text(viewRecord.author.name)

                    Spacer()

                    Text(viewRecord.timeAgoString)
                }

                Text(viewRecord.value.text)

                if let embeds = viewRecord.embeds {
                    ForEach(embeds) { embed in
                        switch(embed) {
                        case .imagesView(let view):
                            EmbedImagesViewView(view: view)

                        case .recordView(let view):
                            EmbedRecordViewView(view: view)

                        case .recordWithMediaView(_):
                            EmptyView()

                        case .externalView(let view):
                            EmbedExternalViewViewView(view: view)

                        case .videoView(let view):
                            EmbedVideoViewView(view: view)
                        }
                    }
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(.gray, lineWidth: 1)
            )

        case .recordViewNotFound(let viewNotFound):
            EmbedRecordViewNotFoundView(viewNotFound: viewNotFound)

        case .recordViewDetached(let viewDetached):
            EmbedRecordViewDetachedView(viewDetached: viewDetached)

        case .recordViewBlocked(let viewBlocked):
            EmbedRecordViewBlockedView(viewBlocked: viewBlocked)

        case .labelerView(_):
            EmptyView()

        case .graphListView(_):
            EmptyView()

        case .feedGeneratorView(_):
            EmptyView()

        case .starterPackViewBasic(_):
            EmptyView()
        }
    }
}
