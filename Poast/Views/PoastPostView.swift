//
//  PoastPostView.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import SwiftUI

struct PoastPostView<PostCollectionViewModel: ObservableObject & PoastPostCollectionHosting>: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var postViewModel: PoastPostViewModel
    @ObservedObject var postCollectionViewModel: PostCollectionViewModel

    @State var replyTo: String?
    @State var showingProfileView: Bool = false
    @State var showingThreadView: Bool = false

    let isParent: Bool

    var body: some View {
        HStack(alignment: .top) {
            Button {
                showingProfileView = true
            } label: {
                VStack {
                    PoastAvatarView(size: .small,
                                    url: postViewModel.post.author.avatar ?? "")
                    .padding(.bottom, 10)
                    .padding(.top, 10)

                    if(isParent == true) {
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 2)
                    }
                }
            }.buttonStyle(.plain)

            Button {
                showingThreadView = true
            } label: {
                VStack(alignment: .leading) {
                    Spacer()

                    PoastPostHeaderView(authorName: postViewModel.post.author.name,
                                        timeAgo: postViewModel.timeAgoString)

                    if let replyTo = replyTo {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward.fill")

                            Text(replyTo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        Spacer()
                    } else if let repostedBy = postViewModel.post.repostedBy {
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

                    Text(postViewModel.post.text)

                    Spacer()

                    if let embed = postViewModel.post.embed {
                        PoastPostEmbedView(postViewModel: postViewModel,
                                           embed: embed)
                    }

                    Spacer()

                    PoastPostInteractionView(postViewModel: postViewModel,
                                             postCollectionViewModel: postCollectionViewModel)

                    Spacer()
                }
            }.buttonStyle(.plain)
        }
        .navigationDestination(isPresented: $showingProfileView) {
            PoastProfileView(profileViewModel: PoastProfileViewModel(handle: postViewModel.post.author.handle))
        }
        .navigationDestination(isPresented: $showingThreadView) {
            PoastThreadView(threadViewModel: PoastThreadViewModel(uri: postViewModel.post.uri))
        }
        .task {
            if(isParent == true) {
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
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let account = PoastAccountObject(context: managedObjectContext)

    account.uuid = UUID()
    account.created = Date()
    account.handle = "@foobar.baz"
    account.host = URL(string: "https://bsky.social")!

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = account.uuid
    session.did = ""

    let user = PoastUser()

    user.accountSession = (account: account, session: session)

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

    let timelineViewModel = PoastFeedTimelineViewModel(algorithm: "")

    return PoastPostView(postViewModel: PoastPostViewModel(post: post),
                         postCollectionViewModel: timelineViewModel,
                         isParent: false)
    .environmentObject(user)
}
