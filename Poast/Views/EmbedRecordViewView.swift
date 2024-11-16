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

            Text(viewRecord.author.name)
            Text(viewRecord.value.text)

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

//            VStack(alignment: .leading) {
//                if let media = media {
//                    switch(media) {
//                    case .imagesView(let images):
//                        EmbedImagesView(images: images)
//
//                    case .externalView(let external):
//                        PostEmbedExternalView(external: external)
//
//                    case .unknown:
//                        EmptyView()
//                    }
//                }
//
//
//                PoastPostHeaderView(authorName: recordRecord.author.name,
//                                    timeAgo: postViewModel.timeAgoString)
//
//                Text(recordRecord.text)
//            }
//
//            .padding()
//            .overlay(
//                RoundedRectangle(cornerRadius: 8.0)
//                    .stroke(.gray, lineWidth: 1))
//            .task {
//                guard let session = user.session else {
//                    return
//                }
//
//                switch(await self.postViewModel.getPost(session: session, uri: recordRecord.uri)) {
//                case .success(let feedPostView):
//                    self.feedPostView = feedPostView
//
//                case .failure(_):
//                    break
//                }
//            }
//
//        default:
//            EmptyView()
//        }
}
