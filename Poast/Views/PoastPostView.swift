//
//  PoastPostView.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import SwiftUI

fileprivate let avatarWidth = 50.0

struct PoastPostView: View {
    @State var postViewModel: PoastPostViewModel
    @State var post: PoastFeedViewPostModel

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                AsyncImage(url: URL(string: self.post.author.avatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.green)
                        .frame(width: avatarWidth, height: avatarWidth)
                }
                .frame(width: avatarWidth, height: avatarWidth)
                .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Spacer()

                PoastPostHeaderView(authorName: post.author.name,
                                    timeAgo: postViewModel.getTimeAgo(date: post.date))

                if let repostedBy = self.post.repostedBy {
                    Spacer()

                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .bold()

                        Text(repostedBy.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                Text(post.text)

                Spacer()

                if let embed = post.embed {
                    PoastPostEmbedView(postViewModel: self.$postViewModel, embed: embed)
                }

                Spacer()

                PoastPostInteractionView(postViewModel: $postViewModel,
                                         postURI: post.uri,
                                         postCID: post.cid,
                                         replyCount: post.replyCount,
                                         repostCount: post.repostCount,
                                         likeCount: post.likeCount,
                                         replyDisabled: post.replyDisabled,
                                         reposted: post.repost,
                                         liked: post.like)

                Spacer()
            }
        }
    }
}

#Preview {
    let post = PoastFeedViewPostModel(
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
        parent: .post(PoastFeedPostViewModel(cid: "",
                                             uri: "",
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
                                             date: Date() - 1000,
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

    return PoastPostView(postViewModel: PoastPostViewModel(), post: post)
}
