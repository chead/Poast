//
//  PoastPostFeedView.swift
//  Poast
//
//  Created by Christopher Head on 10/24/24.
//

import SwiftUI

struct PoastFollowingFeedView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var followingFeedViewModel: FollowingFeedViewModel

    @State var showingComposeSheet: Bool = false
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()
    @State var hasAppeared: Bool = false

    var body: some View {
        List {
            ForEach(followingFeedViewModel.posts) { post in
                PoastFeedPostView(feedViewModel: followingFeedViewModel,
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  post: post)
            }
        }
        .listStyle(.plain)
        .navigationDestination(item: $showingProfileHandle) { profileHandle in
            if let session = user.session {
                PoastProfileView(profileViewModel: ProfileViewViewModel(session: session,
                                                                         handle: profileHandle),
                                 authorFeedViewModel: AuthorFeedViewModel(session: session,
                                                                               modelContext: modelContext,
                                                                               actor: profileHandle,
                                                                               filter: .postsNoReplies),
                                 repliesFeedViewModel: AuthorFeedViewModel(session: session,
                                                                                modelContext: modelContext,
                                                                                actor: profileHandle),
                                 mediaFeedViewModel: AuthorFeedViewModel(session: session,
                                                                              modelContext: modelContext,
                                                                              actor: profileHandle,
                                                                              filter: .postsWithMedia),
                                 likesFeedViewModel: LikesFeedViewModel(session: session,
                                                                             modelContext: modelContext,
                                                                             actor: profileHandle))
            } else {
                EmptyView()
            }
        }
        .navigationDestination(item: $showingThreadURI) { threadURI in
            PoastThreadView(threadViewModel: ThreadViewModel(uri: threadURI),
                            interacted: $interacted)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Poast")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingComposeSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingComposeSheet) {
            PoastPostComposeView(showingComposeView: $showingComposeSheet)
                .interactiveDismissDisabled(true)
        }
        .refreshable {
            _ = await followingFeedViewModel.refreshPosts()
        }
        .task {
            if(!hasAppeared) {
                _ = await followingFeedViewModel.refreshPosts()
                
                hasAppeared.toggle()
            }
        }
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: PoastAccountModel.self, configurations: config)
//
//    let account = PoastAccountModel(uuid: UUID(),
//                                    created: Date(),
//                                    handle: "@foobar.baz",
//                                    host: URL(string: "https://bsky.social")!,
//                                    session: nil)
//
//    let session = PoastSessionModel(account: account,
//                                    did: "",
//                                    created: Date())
//
//    let user = PoastUser()
//
//    user.session = session
//
//    return PoastFeedView()
//        .environmentObject(user)
//        .modelContainer(for: container)
//}
