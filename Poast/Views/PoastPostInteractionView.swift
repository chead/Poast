//
//  PoastPostInteractionView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI
import SwiftATProto

struct PoastPostInteractionView: View {
    @EnvironmentObject var user: PoastUser

    @Binding var postViewModel: PoastPostViewModel

    let post: PoastPostModel

    @State var repostDelta = 0

    @State var like: ATProtoRepoStrongRef?

    var body: some View {
        HStack {
            Button(action: {

            }, label: {
                HStack {
                    Image(systemName: "bubble")
                    Text("\(post.replyCount)")
                }
            })
            .disabled(post.replyDisabled)

            Spacer()

            Button(action: {
                
            }, label: {
                HStack {
                    if(post.repost != nil || repostDelta > 0) {
                        Image(systemName: "repeat")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "repeat")
                    }

                    Text("\(post.repostCount + repostDelta)")
                }
            })

            Spacer()

            Button(action: {
                Task {
                    guard let accountSession = user.accountSession else { return }

                    if(post.like != nil || like != nil) {
                        var uri = ""

                        if let postLike = post.like {
                            uri = postLike
                        } else if let localLike = like {
                            uri = localLike.uri
                        }

                        let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

                        if(await postViewModel.unlikePost(session: accountSession.session,
                                                              rkey: String(rkey)) == nil) {
                            like = nil
                        }
                    } else {
                        switch(await postViewModel.likePost(session: accountSession.session,
                                                            uri: post.uri,
                                                            cid: post.cid)) {
                        case.success(let likePostResponse):
                            like = ATProtoRepoStrongRef(uri: likePostResponse.uri,
                                                        cid: likePostResponse.cid)

                        case .failure(_):
                            break
                        }
                    }
                }
            }, label: {
                HStack {
                    if(post.like != nil || like != nil) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                    }

                    Text("\(post.likeCount + (like != nil ? 1 : 0))")
                }
            })

            Spacer()

            Button(action: {}, label: {
                Image(systemName: "ellipsis")
            })
        }
        .task {

        }
    }
}

#Preview {
    let post = PoastPostModel(
        id: UUID(),
        uri: "",
        cid: "",
        text: "Child post",
        author: PoastProfileModel(
            did: "",
            handle: "foobar.net",
            displayName: "Fooooooooooooooo bar",
            description: "Lorem Ipsum",
            avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
            banner: "",
            followsCount: 10,
            followersCount: 123,
            postsCount: 4123,
            labels: []),
        replyCount: 1,
        likeCount: 0,
        repostCount: 10,
        root: nil,
        parent: .post(PoastPostModel(id: UUID(),
                                     uri: "",
                                     cid: "",
                                     text: "Parent post",
                                     author: PoastProfileModel(
                                        did: "",
                                        handle: "barbaz.net",
                                        displayName: "Barbaz",
                                        description: "Lorem Ipsum",
                                        avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                                        banner: "",
                                        followsCount: 1,
                                        followersCount: 3,
                                        postsCount: 551,
                                        labels: []),
                                     replyCount: 0,
                                     likeCount: 0,
                                     repostCount: 0,
                                     root: nil,
                                     parent: nil,
                                     embed: nil,
                                     date: Date() - 1000,
                                     repostedBy: nil,
                                     like: nil,
                                     repost: nil,
                                     replyDisabled: false)),
        embed: PoastPostEmbedModel.images([
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
        ]),
        date: Date(timeIntervalSinceNow: -10),
        repostedBy: nil,
        like: "foo",
        repost: nil,
        replyDisabled: false)

    return PoastPostInteractionView(postViewModel: .constant(PoastPostViewModel()),
                                    post: post)
}
