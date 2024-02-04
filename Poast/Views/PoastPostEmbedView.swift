//
//  PoastPostEmbedView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastPostEmbedView: View {
    @EnvironmentObject var session: PoastSessionObject

    @Binding var postViewModel: PoastPostViewModel

    @State var embed: PoastPostEmbedModel
    @State var recordRecord: PoastFeedPostViewModel? = nil

    var body: some View {
        switch(self.embed) {
        case .images(let images):
            HStack {
                ForEach(images) { image in
                    AsyncImage(url: URL(string: image.thumb)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(.green)
                    }
                    .cornerRadius(8.0)
                }
            }
            .padding()

        case .record(let record):
            switch(record) {
            case .record(let recordRecord):
                VStack {
                    PoastPostHeaderView(authorName: self.recordRecord?.author.name ?? "",
                                        timeAgo: self.postViewModel.getTimeAgo(date: recordRecord.indexedAt))

                    Text(self.recordRecord?.text ?? "")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8.0)
                        .stroke(.gray, lineWidth: 1)
                )
                .task {
                    switch(await self.postViewModel.getPost(session: self.session, uri: recordRecord.uri)) {
                    case .success(let poastFeedPostViewModel):
                        self.recordRecord = poastFeedPostViewModel

                    case .failure(let error):
                        break
                    }
                }

            default:
                EmptyView()
            }

        default:
            EmptyView()
        }
    }
}

#Preview {
    let imageEmbed = PoastPostEmbedModel.images([
        PoastPostEmbedImageModel(fullsize: "",
                                 thumb: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
                                 alt: "Some alt text",
                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
                                                                              height: 250)),
        PoastPostEmbedImageModel(fullsize: "",
                                 thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg",
                                 alt: "Some alt text",
                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
                                                                              height: 250))
    ])

    return PoastPostEmbedView(postViewModel: .constant(PoastPostViewModel()), embed: imageEmbed)
}
