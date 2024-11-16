//
//  PostEmbedView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI
import SwiftBluesky

struct PostViewEmbedView: View {
    @EnvironmentObject var user: UserModel

    @State var embed: Bsky.Feed.PostView.EmbedType

    var body: some View {
        switch(embed) {
        case .imagesView(let view):
            EmbedImagesViewView(view: view)

        case .externalView(let view):
            EmbedExternalViewViewView(view: view)

        case .recordView(let view):
            EmbedRecordViewView(view: view)

        case .recordWithMediaView(let view):
            EmbedRecordWithMediaViewView(view: view)

        case .videoView(let view):
            EmbedVideoViewView(view: view)
        }
    }
}

//#Preview {
//    let imagesEmbed = PoastPostEmbedModel.images([
//        PoastPostEmbedImageModel(fullsize: "",
//                                 thumb: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:etdcb47v54mwv2wdufhi4tu6/bafkreih3kov57zymtwipk5sp6g73rcewf2ip5djcvp4opb2epmd76yqbna@jpeg",
//                                 alt: "Some alt text",
//                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                              height: 250)),
//        PoastPostEmbedImageModel(fullsize: "",
//                                 thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg",
//                                 alt: "Some alt text",
//                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                              height: 250)),
//        PoastPostEmbedImageModel(fullsize: "",
//                                 thumb: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
//                                 alt: "Some alt text",
//                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                              height: 250)),
//        PoastPostEmbedImageModel(fullsize: "",
//                                 thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg",
//                                 alt: "Some alt text",
//                                 aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                              height: 250))
//    ])
//
//    return PoastPostEmbedView(postViewModel: .constant(PoastPostViewModel()), embed: imagesEmbed)
//}
//
//#Preview {
//    let externalEmbed = PoastPostEmbedModel.external(PoastPostEmbedExternalModel(uri: "https://bsky.app",
//                                                                                     description: "Bluesky",
//                                                                                     thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg"))
//
//    return PoastPostEmbedView(postViewModel: .constant(PoastPostViewModel()), embed: externalEmbed)
//}
