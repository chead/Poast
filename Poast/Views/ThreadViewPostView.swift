//
//  ThreadViewPostView.swift
//  Poast
//
//  Created by Christopher Head on 11/16/24.
//

import SwiftUI
import SwiftBluesky

struct ThreadViewPostRow: Equatable, Hashable, Identifiable {
    let id = UUID()
    let threadViewPost: Bsky.Feed.ThreadViewPost.PostType

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func ==(lhs: ThreadViewPostRow, rhs: ThreadViewPostRow) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ThreadViewPostView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var threadViewPostViewModel: ThreadViewPostViewModel

    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil

    @Binding var interacted: Date

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(threadViewPostViewModel.parentThreadViewPosts.map { ThreadViewPostRow(threadViewPost: $0) }) { threadViewPostRow in
                    switch(threadViewPostRow.threadViewPost) {
                    case .threadViewPost(let threadViewPost):
                        PostViewView(postViewViewModel: PostViewViewModel(postView: threadViewPost.post),
                                     showingProfileHandle: $showingProfileHandle,
                                     showingThreadURI: $showingThreadURI,
                                     interacted: $interacted,
                                     showThread: true)

                    case .blockedPost(_):
                        BlockedPostView()
                        
                    case .notFoundPost(_):
                        NotFoundPostView()
                    }
                }
                
                if let threadViewPost = threadViewPostViewModel.threadViewPost {
                    PostViewView(postViewViewModel: PostViewViewModel(postView: threadViewPost.post),
                                 showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted)
                    .id(1)
                }

                ForEach((threadViewPostViewModel.threadViewPost?.replies ?? []).map { ThreadViewPostRow(threadViewPost: $0) }) { threadViewPostRow in
                    switch(threadViewPostRow.threadViewPost) {
                    case .threadViewPost(let threadViewPost):
                        PostViewView(postViewViewModel: PostViewViewModel(postView: threadViewPost.post),
                                     showingProfileHandle: $showingProfileHandle,
                                     showingThreadURI: $showingThreadURI,
                                     interacted: $interacted,
                                     showThread: true)

                    case .blockedPost(_):
                        BlockedPostView()
                        
                    case .notFoundPost(_):
                        NotFoundPostView()
                    }
                }
            }
            .listStyle(.plain)
            .onChange(of: threadViewPostViewModel.threadViewPost) { oldValue, newValue in
                proxy.scrollTo(1, anchor: .top)
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                ThreadViewPostView(threadViewPostViewModel: ThreadViewPostViewModel(uri: threadURI),
                                   interacted: $interacted)
            }
        }
        .task {
            if let session = user.session {
                _ = await threadViewPostViewModel.getPostThread(session: session)
            }
        }
    }
}

//#Preview {
//    ThreadViewPostView()
//}
