//
//  PoastThreadView.swift
//  Poast
//
//  Created by Christopher Head on 2/13/24.
//

import SwiftUI

struct PoastThreadParentPostView: View {
    @ObservedObject var threadViewModel: PoastThreadViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    let posts: [PoastThreadModel]

    init(threadViewModel: PoastThreadViewModel, showingProfileHandle: Binding<String?>, showingThreadURI: Binding<String?>, interacted: Binding<Date>, threadPost: PoastThreadPostModel) {
        self._interacted = interacted
        self.threadViewModel = threadViewModel

        self._showingProfileHandle = showingProfileHandle
        self._showingThreadURI = showingThreadURI

        var posts: [PoastThreadModel] = []
        var parent = threadPost.parent

        while(parent != nil) {
            posts.append(parent!)

            switch(parent) {
            case .threadPost(let threadPost):
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

            case .threadPost(let threadPost):
                PoastPostView(postViewModel: PoastPostViewModel(post: threadPost.post),
                              showingProfileHandle: $showingProfileHandle,
                              showingThreadURI: $showingThreadURI,
                              interacted: $interacted,
                              isParent: false)
            }
        }
    }
}

struct PoastThreadPostView: View {
    @ObservedObject var threadViewModel: PoastThreadViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    let threadPost: PoastThreadPostModel

    var body: some View {
        PoastPostView(postViewModel: PoastPostViewModel(post: threadPost.post),
                      showingProfileHandle: $showingProfileHandle,
                      showingThreadURI: $showingThreadURI,
                      interacted: $interacted,
                      isParent: false)
        .id(1)

        ForEach(threadPost.replies ?? []) { reply in
            switch(reply) {
            case .blocked(_):
                Text("Blocked Post")

            case .notFound(_):
                Text("Post Not Found")

            case .threadPost(let threadPost):
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

    @EnvironmentObject var user: PoastUser

    @StateObject var threadViewModel: PoastThreadViewModel

    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil

    @Binding var interacted: Date

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if let threadPost = threadViewModel.threadPost {
                    PoastThreadParentPostView(threadViewModel: threadViewModel,
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
                    PoastProfileView(profileViewModel: PoastProfileViewModel(session: session,
                                                                             handle: profileHandle),
                                     authorFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                                   modelContext: modelContext,
                                                                                   actor: profileHandle,
                                                                                   filter: .postsNoReplies),
                                     repliesFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                                    modelContext: modelContext,
                                                                                    actor: profileHandle),
                                     mediaFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                                  modelContext: modelContext,
                                                                                  actor: profileHandle,
                                                                                  filter: .postsWithMedia),
                                     likesFeedViewModel: PoastLikesFeedViewModel(session: session,
                                                                                 modelContext: modelContext,
                                                                                 actor: profileHandle))
                }
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
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
    let account = PoastAccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = PoastSessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = PoastUser(session: session)

    PoastThreadView(threadViewModel: PoastThreadViewModel(uri: ""),
                    interacted: .constant(Date()))
    .environmentObject(user)
}
