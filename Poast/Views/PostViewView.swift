//
//  PostViewView.swift
//  Poast
//
//  Created by Christopher Head on 1/25/24.
//

import SwiftUI
import SwiftBluesky
import SwiftData

struct PostViewView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    var postViewViewModel: PostViewViewModel

    @State var replyTo: String? = nil

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?

    let isParent: Bool
    let showThread: Bool

    init(postViewViewModel: PostViewViewModel, showingProfileHandle: Binding<String?>, showingThreadURI: Binding<String?>, isParent: Bool = false, showThread: Bool = false) {
        self.postViewViewModel = postViewViewModel

        self._showingProfileHandle = showingProfileHandle
        self._showingThreadURI = showingThreadURI

        self.isParent = isParent
        self.showThread = showThread
    }

    var body: some View {
        HStack(alignment: .top) {
            Button {
                showingProfileHandle = postViewViewModel.postView.author.handle
            } label: {
                VStack {
                    AvatarView(size: .medium,
                               url: URL(string: postViewViewModel.postView.author.avatar ?? ""))
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
                if(showThread) {
                    showingThreadURI = postViewViewModel.postView.uri
                }
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(postViewViewModel.postView.author.name)
                            .bold()
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        Text(postViewViewModel.postView.timeAgoString)

                        Spacer()
                    }

                    if let replyTo = replyTo {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward.fill")

                            Text(replyTo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        Spacer()
                    }

                    if case let .post(postRecord) = postViewViewModel.postView.record {
                        Text(postRecord.text)

                        Spacer()
                    }

                    if let embed = postViewViewModel.postView.embed {
                        PostViewEmbedView(embed: embed)

                        Spacer()
                    }

                    PostViewInteractionView(postViewInteractionViewModel: PostViewInteractionViewModel(modelContext: modelContext,
                                                                                                       postView: postViewViewModel.postView))
                }
            }
            .buttonStyle(.plain)
        }
        .task {
            if isParent,
               case let .post(postRecord) = postViewViewModel.postView.record,
               let parent = postRecord.reply?.parent,
               let session = user.session {
                switch(await postViewViewModel.getPost(session: session, uri: parent.uri)) {
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
//    let modelContainer = try! ModelContainer(for: AccountModel.self,
//                                             LikeInteractionModel.self,
//                                             RepostInteractionModel.self,
//                                             MuteInteractionModel.self,
//                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//
//    let user = UserModel()
//
//    let profile = ActorProfileViewModel(
//                    did: "",
//                    handle: "foobar.net",
//                    displayName: "Fooooooooooooooo bar",
//                    desc: "Lorem Ipsum",
//                    avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
//                    banner: "",
//                    followsCount: 10,
//                    followersCount: 123,
//                    postsCount: 4123,
//                    labels: [])
//
//    let post = FeedFeedViewPostModel(uri: "",
//                                   cid: "",
//                                   text: "A post!",
//                                   author: profile,
//                                   replyCount: 1,
//                                   likeCount: 0,
//                                   repostCount: 10,
//                                   root: nil,
//                                   parent: .post(FeedFeedViewPostModel(uri: "",
//                                                                       cid: "",
//                                                                       text: "Parent post",
//                                                                       author: profile,
//                                                                       replyCount: 0,
//                                                                       likeCount: 0,
//                                                                       repostCount: 0,
//                                                                       root: nil,
//                                                                       parent: nil,
//                                                                       embed: nil,
//                                                                       date: Date() - 1000,
//                                                                       repostedBy: nil,
//                                                                       like: nil,
//                                                                       repost: nil,
//                                                                       threadMuted: false,
//                                                                       replyDisabled: false,
//                                                                       embeddingDisabled: false,
//                                                                       pinned: false)),
//                                     embed: nil,
//                                     date: Date(timeIntervalSinceNow: -10),
//                                     repostedBy: nil,
//                                     like: "foo",
//                                     repost: nil,
//                                     threadMuted: false,
//                                     replyDisabled: false,
//                                     embeddingDisabled: false,
//                                     pinned: false)
//
//    PostView(postViewModel: PostViewModel(post: post),
//                  replyTo: nil,
//                  showingProfileHandle: .constant(nil),
//                  showingThreadURI: .constant(nil),
//                  interacted: .constant(Date()),
//                  isParent: false)
//    .modelContainer(modelContainer)
//    .environmentObject(user)
//}
