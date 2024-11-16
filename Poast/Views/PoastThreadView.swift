//
//  ThreadParentPostView.swift
//  Poast
//
//  Created by Christopher Head on 2/13/24.
//

import SwiftUI

struct ThreadParentPostView: View {
    @ObservedObject var threadViewModel: ThreadViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    let posts: [FeedThreadViewPostPostModel]

    init(threadViewModel: ThreadViewModel, showingProfileHandle: Binding<String?>, showingThreadURI: Binding<String?>, interacted: Binding<Date>, threadPost: FeedThreadViewPostModel) {
        self._interacted = interacted
        self.threadViewModel = threadViewModel

        self._showingProfileHandle = showingProfileHandle
        self._showingThreadURI = showingThreadURI

        var posts: [FeedThreadViewPostPostModel] = []
        var parent = threadPost.parent

        while(parent != nil) {
            posts.append(parent!)

            switch(parent) {
            case .threadViewPost(let threadPost):
                parent = threadPost.parent

            default:
                parent = nil
            }
        }

        self.posts = posts.reversed()
    }

    var body: some View {
        ForEach(posts) { post in
            switch(post) {
            case .blocked(_):
                Text("Blocked Post")

            case .notFound(_):
                Text("Post Not Found")

            case .threadViewPost(let threadViewPost):
//                PostView(postViewModel: PostViewModel(post: threadPost.post),
//                              showingProfileHandle: $showingProfileHandle,
//                              showingThreadURI: $showingThreadURI,
//                              interacted: $interacted,
//                              isParent: false)
                EmptyView()
            }
        }
    }
}

struct PoastThreadPostView: View {
    @ObservedObject var threadViewModel: ThreadViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    let threadPost: FeedThreadViewPostModel

    var body: some View {
//        PostView(postViewModel: PostViewModel(post: threadPost.post),
//                      showingProfileHandle: $showingProfileHandle,
//                      showingThreadURI: $showingThreadURI,
//                      interacted: $interacted,
//                      isParent: false)
//        .id(1)

        ForEach(threadPost.replies ?? []) { reply in
            switch(reply) {
            case .blocked(_):
                Text("Blocked Post")

            case .notFound(_):
                Text("Post Not Found")

            case .threadViewPost(let threadPost):
                PoastThreadPostView(threadViewModel: threadViewModel,
                                    showingProfileHandle: $showingProfileHandle,
                                    showingThreadURI: $showingThreadURI,
                                    interacted: $interacted,
                                    threadPost: threadPost)
                .padding(.leading, 40)
            }
        }
    }
}


struct PoastThreadView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var threadViewModel: ThreadViewModel

    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil

    @Binding var interacted: Date

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if let threadPost = threadViewModel.threadPost {
                    ThreadParentPostView(threadViewModel: threadViewModel,
                                              showingProfileHandle: $showingProfileHandle,
                                              showingThreadURI: $showingThreadURI,
                                              interacted: $interacted,
                                              threadPost: threadPost)

                    PoastThreadPostView(threadViewModel: threadViewModel,
                                        showingProfileHandle: $showingProfileHandle,
                                        showingThreadURI: $showingThreadURI,
                                        interacted: $interacted,
                                        threadPost: threadPost)
                }
            }
            .listStyle(.plain)
            .onChange(of: threadViewModel.threadPost) { oldValue, newValue in
                proxy.scrollTo(1, anchor: .top)
            }
            .navigationDestination(item: $showingProfileHandle) { profileHandle in
                if let session = user.session {
                    ProfileView(profileViewModel: ProfileViewViewModel(session: session,
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
                }
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: ThreadViewModel(uri: threadURI),
                                interacted: $interacted)
            }
        }
        .task {
            if let session = user.session {
                _ = await threadViewModel.getThread(session: session)
            }
        }
    }
}

#Preview {
    let account = AccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = SessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = UserModel(session: session)

    PoastThreadView(threadViewModel: ThreadViewModel(uri: ""),
                    interacted: .constant(Date()))
    .environmentObject(user)
}
