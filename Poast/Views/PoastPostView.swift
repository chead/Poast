//
//  PoastPostView.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import SwiftUI
import SwiftData

enum PoastPoastViewAction {
    case thread(String)
    case profile(String)
}

struct PoastPostView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: PoastUser

    var postViewModel: PoastPostViewModel

    @State var replyTo: String? = nil

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    let isParent: Bool

    var body: some View {
        HStack(alignment: .top) {
            Button {
                showingProfileHandle = postViewModel.post.author.handle
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
                showingThreadURI = postViewModel.post.uri
            } label: {
                VStack(alignment: .leading) {
                    PoastPostHeaderView(authorName: postViewModel.post.author.name,
                                        timeAgo: postViewModel.timeAgoString)

                    if let replyTo = replyTo {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward.fill")

                            Text(replyTo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
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

                    if let embed = postViewModel.post.embed {
                        Spacer()

                        PoastPostEmbedView(postViewModel: postViewModel,
                                           embed: embed)
                    }

                    Spacer()

                    PoastPostInteractionView(postInteractionViewModel: PoastPostInteractionViewModel(modelContext: modelContext,
                                                                                                     post: postViewModel.post),
                                             interacted: $interacted)

                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
        .task {
            if(isParent == true) {
                if let parent = postViewModel.post.parent {
                    guard let session = user.session else {
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
    let modelContainer = try! ModelContainer(for: PoastAccountModel.self,
                                             PoastPostLikeInteractionModel.self,
                                             PoastPostRepostInteractionModel.self,
                                             PoastThreadMuteInteractionModel.self,
                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    let account = PoastAccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = PoastSessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = PoastUser()

    let profile = PoastProfileModel(
                    did: "",
                    handle: "foobar.net",
                    displayName: "Fooooooooooooooo bar",
                    desc: "Lorem Ipsum",
                    avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                    banner: "",
                    followsCount: 10,
                    followersCount: 123,
                    postsCount: 4123,
                    labels: [])

    let post = PoastVisiblePostModel(uri: "",
                                   cid: "",
                                   text: "A post!",
                                   author: profile,
                                   replyCount: 1,
                                   likeCount: 0,
                                   repostCount: 10,
                                   root: nil,
                                   parent: .post(PoastVisiblePostModel(uri: "",
                                                                       cid: "",
                                                                       text: "Parent post",
                                                                       author: profile,
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
                                                                       threadMuted: false,
                                                                       replyDisabled: false,
                                                                       embeddingDisabled: false,
                                                                       pinned: false)),
                                     embed: nil,
                                     date: Date(timeIntervalSinceNow: -10),
                                     repostedBy: nil,
                                     like: "foo",
                                     repost: nil,
                                     threadMuted: false,
                                     replyDisabled: false,
                                     embeddingDisabled: false,
                                     pinned: false)

    PoastPostView(postViewModel: PoastPostViewModel(post: post),
                  replyTo: nil,
                  showingProfileHandle: .constant(nil),
                  showingThreadURI: .constant(nil),
                  interacted: .constant(Date()),
                  isParent: false)
    .modelContainer(modelContainer)
    .environmentObject(user)
}
