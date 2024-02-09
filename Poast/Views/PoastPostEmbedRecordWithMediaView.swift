//
//  PoastPostEmbedRecordWithMediaView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI

struct PoastPostEmbedRecordWithMediaView: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var postViewModel: PoastPostViewModel

    @State var feedPostView: PoastPostModel? = nil

    let record: PoastPostEmbedRecordModel
    let media: PoastPostEmbedRecordWithMediaMediaModel?

    var body: some View {
        switch(record) {
        case .record(let recordRecord):
            VStack(alignment: .leading) {
                if let media = media {
                    switch(media) {
                    case .imagesView(let images):
                        PoastPostEmbedImagesView(images: images)

                    case .externalView(let external):
                        PoastPostEmbedExternalView(external: external)

                    case .unknown:
                        EmptyView()
                    }
                }

                PoastPostHeaderView(authorName: feedPostView?.author.name ?? "",
                                    timeAgo: postViewModel.timeAgoString)
                
                Text(feedPostView?.text ?? "")
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(.gray, lineWidth: 1)
            )
            .task {
                guard let session = user.accountSession?.session else {
                    return
                }

                switch(await self.postViewModel.getPost(session: session, uri: recordRecord.uri)) {
                case .success(let feedPostView):
                    self.feedPostView = feedPostView

                case .failure(_):
                    break
                }
            }

        default:
            EmptyView()
        }
    }
}
