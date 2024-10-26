//
//  PoastPostInteractionView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI
import SwiftData
import SwiftATProto

struct PoastPostInteractionView: View {
    @EnvironmentObject var user: PoastUser

    @StateObject var postInteractionViewModel: PoastPostInteractionViewModel

    @State var showingRepostDialog: Bool = false
    @State var showingMoreConfirmationDialog: Bool = false

    @Binding var interacted: Date

    var body: some View {
        HStack {
            Button(action: {

            }, label: {
                HStack {
                    Image(systemName: "bubble")
                    Text("\(postInteractionViewModel.post.replyCount)")
                }
            })
            .buttonStyle(.plain)
            .disabled(postInteractionViewModel.post.replyDisabled)

            Spacer()

            Button(action: {
                showingRepostDialog = true
            }, label: {
                HStack {
                    if(postInteractionViewModel.isReposted()) {
                        Image(systemName: "repeat")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "repeat")
                    }

                    Text("\(postInteractionViewModel.getRepostCount())")
                }
            })
            .buttonStyle(.plain)
            .confirmationDialog("Repost",
                                isPresented: $showingRepostDialog,
                                titleVisibility: .hidden) {
                Button(postInteractionViewModel.isReposted() ? "Undo repost" : "Repost") {
                    Task {
                        guard let session = user.session else {
                            return
                        }

                        await postInteractionViewModel.toggleRepostPost(session: session)
                    }
                }

                Button("Quote Post") {}
            }

            Spacer()

            Button(action: {
                Task {
                    guard let session = user.session else {
                        return
                    }

                    await postInteractionViewModel.toggleLikePost(session: session)
                }

                interacted = Date()
            }, label: {
                HStack {
                    if(postInteractionViewModel.isLiked()) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                    }

                    Text("\(postInteractionViewModel.getLikeCount())")
                }
            })
            .buttonStyle(.plain)

            Spacer()

            Button(action: {
                showingMoreConfirmationDialog = true
            }, label: {
                Image(systemName: "ellipsis")
            })
            .buttonStyle(.plain)
            .confirmationDialog("More",
                                isPresented: $showingMoreConfirmationDialog,
                                titleVisibility: .hidden) {
//                Button("Translate") {}

                Button("Copy post text") {
                    UIPasteboard.general.string = postInteractionViewModel.post.text
                }

                if postInteractionViewModel.canSharePost(), let postShareURL = postInteractionViewModel.postShareURL() {
                    ShareLink(item: postShareURL)
                }

                Button(postInteractionViewModel.isThreadMuted() ? "Unmute thread" : "Mute thread") {
                    Task {
                        guard let session = user.session else {
                            return
                        }

                        await postInteractionViewModel.toggleMutePost(session: session)
                    }
                }

                Button("Hide post") {}

                Button("Report post") {}
            }
        }
        .onAppear {
            postInteractionViewModel.getInteractions()
        }
    }
}

//#Preview {
//    let post = PoastVisiblePostModel(
//        uri: "",
//        cid: "",
//        text: "Child post",
//        author: PoastProfileModel(
//            did: "",
//            handle: "foobar.net",
//            displayName: "Fooooooooooooooo bar",
//            desc: "Lorem Ipsum",
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
//        parent: .post(PoastVisiblePostModel(uri: "",
//                                     cid: "",
//                                     text: "Parent post",
//                                     author: PoastProfileModel(
//                                        did: "",
//                                        handle: "barbaz.net",
//                                        displayName: "Barbaz",
//                                        desc: "Lorem Ipsum",
//                                        avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
//                                        banner: "",
//                                        followsCount: 1,
//                                        followersCount: 3,
//                                        postsCount: 551,
//                                        labels: []),
//                                     replyCount: 0,
//                                     likeCount: 0,
//                                     repostCount: 0,
//                                     root: nil,
//                                     parent: nil,
//                                     embed: nil,
//                                     date: Date() - 1000,
//                                     repostedBy: nil,
//                                     like: nil,
//                                     repost: nil,
//                                     replyDisabled: false)),
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
//        like: nil,
//        repost: nil,
//        replyDisabled: false)
//
//    let postViewModel = PoastPostViewModel(post: post)
//    let timelineViewModel = PoastFeedTimelineViewModel(algorithm: "")
//    let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
//    let modelContainer = try! ModelContainer(for: PoastAccountModel.self, configurations: modelConfiguration)
//
//    PoastPostInteractionView(postInteractionViewModel: PoastPostInteractionViewModel(post: post))
//}
