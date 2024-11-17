//
//  FollowingFeedView.swift
//  Poast
//
//  Created by Christopher Head on 10/24/24.
//

import SwiftUI
import SwiftBluesky

struct FeedViewPostRow: Equatable, Hashable, Identifiable {
    let id = UUID()
    let feedViewPost: Bsky.Feed.FeedViewPost

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func ==(lhs: FeedViewPostRow, rhs: FeedViewPostRow) -> Bool {
        return lhs.id == rhs.id
    }
}

struct FollowingFeedView: View {
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
            ForEach(followingFeedViewModel.posts.map { FeedViewPostRow(feedViewPost: $0) }) { feedViewPostRow in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted,
                                 feedViewPost: feedViewPostRow.feedViewPost)
                .onAppear {
                    Task {
                        if followingFeedViewModel.posts.lastIndex(of: feedViewPostRow.feedViewPost) == followingFeedViewModel.posts.count - 1 {
                            _ = await followingFeedViewModel.updatePosts(cursor: feedViewPostRow.feedViewPost.post.indexedAt)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationDestination(item: $showingProfileHandle) { profileHandle in
            if let session = user.session {
//                ProfileView(profileViewModel: ProfileViewViewModel(session: session,
//                                                                         handle: profileHandle),
//                                 authorFeedViewModel: AuthorFeedViewModel(session: session,
//                                                                               modelContext: modelContext,
//                                                                               actor: profileHandle,
//                                                                               filter: .postsNoReplies),
//                                 repliesFeedViewModel: AuthorFeedViewModel(session: session,
//                                                                                modelContext: modelContext,
//                                                                                actor: profileHandle),
//                                 mediaFeedViewModel: AuthorFeedViewModel(session: session,
//                                                                              modelContext: modelContext,
//                                                                              actor: profileHandle,
//                                                                              filter: .postsWithMedia),
//                                 likesFeedViewModel: LikesFeedViewModel(session: session,
//                                                                             modelContext: modelContext,
//                                                                             actor: profileHandle))
                EmptyView()
            } else {
                EmptyView()
            }
        }
        .navigationDestination(item: $showingThreadURI) { threadURI in
            ThreadViewPostView(threadViewPostViewModel: ThreadViewPostViewModel(uri: threadURI),
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
            PostComposeView(showingComposeView: $showingComposeSheet)
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
