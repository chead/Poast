//
//  PostEmbedRecordWithMediaView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI

struct PostEmbedRecordWithMediaView: View {
    @EnvironmentObject var user: UserModel

    let record: EmbedRecordViewModel
    let media: EmbedRecordWithMediaViewMediaModel?

    var body: some View {
        switch(record) {
        case .record(let recordRecord):
            VStack(alignment: .leading) {
                if let media = media {
                    switch(media) {
                    case .imagesView(let images):
                        PostEmbedImagesView(images: images)

                    case .externalView(let external):
                        PostEmbedExternalView(external: external)

                    case .unknown:
                        EmptyView()
                    }
                }

                if let embeds = recordRecord.embeds {
                    ForEach(embeds) { embed in
                        switch(embed) {
                        case .images(let embedImages):
                            PostEmbedImagesView(images: embedImages)

                        case .recordWithMedia(let embedRecordWithMedia):
//                            PoastPostEmbedRecordWithMediaView(record: record, media: embedRecordWithMedia)
                            EmptyView()

                        default:
                            EmptyView()
                        }
                    }
                }

//                PoastPostHeaderView(authorName: recordRecord.author.name,
//                                    timeAgo: postViewModel.timeAgoString)

//                Text(recordRecord.text)
            }
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

        default:
            EmptyView()
        }
    }
}
