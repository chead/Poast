//
//  PoastParentPostView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastParentPostView: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var postViewModel: PoastPostViewModel
    @ObservedObject var timelineViewModel: PoastTimelineViewModel

    @State var replyTo: String?

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                AsyncImage(url: URL(string: postViewModel.post.author.avatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 50, height: 50)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                Rectangle()
                    .fill(.gray)
                    .frame(width: 2)
            }

            VStack(alignment: .leading) {
                PoastPostHeaderView(authorName: postViewModel.post.author.name,
                                    timeAgo: postViewModel.timeAgoString)

                Spacer()

                if let replyTo = replyTo {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward.fill")

                        Text(replyTo)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Spacer()
                }

                Text(postViewModel.post.text)

                Spacer()

                PoastPostInteractionView(postViewModel: postViewModel,
                                         timelineViewModel: timelineViewModel)

                Spacer()
            }
        }
        .task {
            if let parent = postViewModel.post.parent {
                guard let session = user.accountSession?.session else {
                    return
                }

                var uri = ""

                switch(parent) {
                case .post(let post):
                    uri = post.uri

                case .reference(let reference):
                    uri = reference.uri

                default:
                    break
                }

                switch(await postViewModel.getPost(session: session, uri: uri)) {
                case .success(let grandParentPost):
                    if let grandParentPost = grandParentPost {
                        replyTo = grandParentPost.author.name
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}

//#Preview {
//    let post = PoastPostModel(
//        id: UUID(),
//        uri: "",
//        cid: "",
//        text: "Parent post",
//        author: PoastProfileModel(
//            did: "",
//            handle: "foobar.net",
//            displayName: "Fooooooooooooooo bar",
//            description: "Lorem Ipsum",
//            avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
//            banner: "",
//            followsCount: 10,
//            followersCount: 123,
//            postsCount: 4123,
//            labels: []),
//        replyCount: 1,
//        likeCount: 0,
//        repostCount: 10,
//        root: nil,
//        parent: nil,
//        embed: PoastPostEmbedModel.images([
//            PoastPostEmbedImageModel(fullsize: "",
//                                     thumb: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
//                                     alt: "Some alt text",
//                                     aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                                  height: 250)),
//            PoastPostEmbedImageModel(fullsize: "",
//                                     thumb: "https://vetmed.tamu.edu/news/wp-content/uploads/sites/9/2023/05/AdobeStock_472713009.jpeg",
//                                     alt: "Some alt text",
//                                     aspectRatio: PoastEmbedImageModelAspectRatio(width: 1000,
//                                                                                  height: 250))
//        ]),
//        date: Date(timeIntervalSinceNow: -10),
//        repostedBy: nil,
//        like: "foo",
//        repost: nil,
//        replyDisabled: false)
//
//    return PoastParentPostView(postViewModel: PoastPostViewModel(), post: post)
//}
