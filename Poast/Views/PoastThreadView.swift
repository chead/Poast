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

    let posts: [PoastThreadModel]
    let interaction: (PoastPoastInteractionViewAction) async -> Void

    init(threadViewModel: PoastThreadViewModel, showingProfileHandle: Binding<String?>, showingThreadURI: Binding<String?>, threadPost: PoastThreadPostModel, interaction: @escaping (PoastPoastInteractionViewAction) async -> Void) {
        self.threadViewModel = threadViewModel

        self._showingProfileHandle = showingProfileHandle
        self._showingThreadURI = showingThreadURI

        self.interaction = interaction

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
                              isParent: false,
                              action: { action in
                    switch action {
                    case .profile(let handle):
                        showingProfileHandle = handle

                    case .thread(let uri):
                        showingThreadURI = uri
                    }
                },
                              interaction: interaction)
            }
        }
    }
}

struct PoastThreadPostView: View {
    @ObservedObject var threadViewModel: PoastThreadViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?

    let threadPost: PoastThreadPostModel
    let interaction: (PoastPoastInteractionViewAction) async -> Void

    var body: some View {
        PoastPostView(postViewModel: PoastPostViewModel(post: threadPost.post),
                      isParent: false,
                      action: { action in
            switch action {
            case .profile(let handle):
                showingProfileHandle = handle

            case .thread(let uri):
                if uri != threadViewModel.uri {
                    showingThreadURI = uri
                }
            }
        },
                      interaction: interaction)
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
                                    threadPost: threadPost,
                                    interaction: interaction)

                .padding(.leading, 25)
            }
        }
    }
}


struct PoastThreadView: View {
    @EnvironmentObject var user: PoastUser

    @StateObject var threadViewModel: PoastThreadViewModel

    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if let threadPost = threadViewModel.threadPost {
                    PoastThreadParentPostView(threadViewModel: threadViewModel,
                                              showingProfileHandle: $showingProfileHandle,
                                              showingThreadURI: $showingThreadURI,
                                              threadPost: threadPost,
                                              interaction: { interaction in
                        await handlePostInteraction(interaction: interaction)
                    })

                    PoastThreadPostView(threadViewModel: threadViewModel,
                                        showingProfileHandle: $showingProfileHandle,
                                        showingThreadURI: $showingThreadURI,
                                        threadPost: threadPost,
                                        interaction: { interaction in
                        await handlePostInteraction(interaction: interaction)
                    })
                }
            }
            .listStyle(.plain)
            .onChange(of: threadViewModel.threadPost) { oldValue, newValue in
                proxy.scrollTo(1, anchor: .top)
            }
            .navigationDestination(item: $showingProfileHandle) { profileHandle in
                PoastProfileView(profileViewModel: PoastProfileViewModel(handle: profileHandle))
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI))
            }
        }
        .task {
            if let accountSession = user.accountSession {
                _ = await threadViewModel.getThread(session: accountSession.session)
            }
        }
    }

    func handlePostInteraction(interaction: PoastPoastInteractionViewAction) async -> Void {
        switch interaction {
        case .like(let post):
            guard let accountSession = user.accountSession else { break }

            await threadViewModel.toggleLikePost(session: accountSession.session, post: post)

        case .repost(let post):
            guard let accountSession = user.accountSession else { break }

            await threadViewModel.toggleRepostPost(session: accountSession.session, post: post)

        default:
            break
        }
    }
}

#Preview {
    PoastThreadView(threadViewModel: PoastThreadViewModel(uri: ""))
}
