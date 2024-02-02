//
//  PoastParentPostView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastParentPostView: View {
    @EnvironmentObject var session: PoastSessionObject

    @State var postViewModel: PoastPostViewModel
    @State var post: PoastFeedPostViewModel
    @State var replyTo: String?

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
                        .frame(width: 50, height: 50)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                Rectangle()
                    .fill(.gray)
                    .frame(width: 2)
            }

            VStack(alignment: .leading) {
                PoastPostHeaderView(authorName: self.post.author.name,
                                    timeAgo: self.postViewModel.getTimeAgo(date: self.post.date))

                Spacer()

                if let replyTo = self.replyTo {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward.fill")

                        Text(replyTo)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                Text(self.post.text)

                Spacer()

                PoastPostInteractionView(postViewModel: self.$postViewModel,
                                         replyCount: self.post.replyCount,
                                         repostCount: self.post.repostCount,
                                         likeCount: self.post.likeCount)
                .environmentObject(session)

                Spacer()
            }
        }
        .task {
            if let parent = self.post.parent {
                switch(await self.postViewModel.getPost(session: self.session, uri: parent.uri)) {
                case .success(let grandParentPost):
                    if let grandParentPost = grandParentPost {
                        self.replyTo = grandParentPost.author.name
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = UUID()
    session.did = ""

    let post = PoastFeedPostViewModel(id: "",
                                      uri: "",
                                      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed molestie leo felis, ut ultrices est euismod vitae. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce bibendum iaculis augue, eget luctus purus dapibus ut. Morbi congue, nibh lacinia consequat tempus, lacus nisl eleifend ligula, quis dapibus sem diam ac ex.",
                                      author: PoastProfileModel(did: "",
                                                                handle: "foobar.net",
                                                                displayName: "Foobar",
                                                                description: "Lorem Ipsum",
                                                                avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                                                                banner: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
                                                                followsCount: 10,
                                                                followersCount: 123,
                                                                postsCount: 4123,
                                                                labels: []),
                                      replyCount: 1,
                                      likeCount: 0,
                                      repostCount: 10,
                                      root: nil,
                                      parent: nil,
                                      date: Date())

    return PoastParentPostView(postViewModel: PoastPostViewModel(), post: post)
        .environmentObject(session)
}
