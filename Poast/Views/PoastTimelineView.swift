//
//  PoastTimelineView.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import SwiftUI

enum PoastTimelineViewVerticalLayout {
    case list
    case stack
}

struct PoastTimelineView: View {
    @EnvironmentObject var user: PoastUser

    @StateObject var timelineViewModel: PoastTimelineViewModel

    @State var showingComposerView: Bool = false
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()

    let showingToolbar: Bool
    let verticalLayout: PoastTimelineViewVerticalLayout

    struct ContentView: View {
        @EnvironmentObject var user: PoastUser

        @Binding var interacted: Date
        @Binding var showingComposerView: Bool
        @Binding var showingProfileHandle: String?
        @Binding var showingThreadURI: String?

        let timelineViewModel: PoastTimelineViewModel
        let showingToolbar: Bool
        let verticalLayout: PoastTimelineViewVerticalLayout

        @ViewBuilder
        var body: some View {
            switch verticalLayout {
            case .list:
                List(Array(timelineViewModel.posts.enumerated()), id: \.1.uri) { (index, post) in
                    PostView(interacted: $interacted, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, timelineViewModel: timelineViewModel, post: post)
                        .onAppear {
                            Task {
                                if index == timelineViewModel.posts.count - 1 {
                                    if let session = user.session {
                                        _ = await timelineViewModel.getTimeline(session: session, cursor: post.date)
                                    }
                                }
                            }
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    if let session = user.session {
                        timelineViewModel.clearTimeline()

                        _ = await timelineViewModel.getTimeline(session: session, cursor: Date())
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if(showingToolbar == true) {
                            Button {
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        if(showingToolbar == true) {
                            Text("Poast")
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        if(showingToolbar == true) {
                            Button {
                                showingComposerView = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .sheet(isPresented: $showingComposerView) {
                                EmptyView()
                            }
                        }
                    }
                }

            case .stack:
                ForEach(timelineViewModel.posts, id: \.uri) { post in
                    PostView(interacted: $interacted, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, timelineViewModel: timelineViewModel, post: post)
                }
            }
        }
    }

    struct PostView: View {
        @Binding var interacted: Date
        @Binding var showingComposerView: Bool
        @Binding var showingProfileHandle: String?
        @Binding var showingThreadURI: String?

        let timelineViewModel: PoastTimelineViewModel
        let post: PoastVisiblePostModel

        @ViewBuilder
        var body: some View {
            if let parent = post.parent {
                switch(parent) {
                case .post(let parentPost):
                    PoastPostView(postViewModel: PoastPostViewModel(post: parentPost),
                                  interacted: $interacted,
                                  isParent: true,
                                  action: { action in
                        switch action {
                        case .profile(let handle):
                            showingProfileHandle = handle

                        case .thread(let uri):
                            showingThreadURI = uri
                        }
                    })

                case .reference(_):
                    EmptyView()

                case .notFound(_):
                    Text("Post not found")

                case .blocked(_, _):
                    Text("Blocked post")
                }
            }

            PoastPostView(postViewModel: PoastPostViewModel(post: post),
                          interacted: $interacted,
                          isParent: false,
                          action: { action in
                switch action {
                case .profile(let handle):
                    showingProfileHandle = handle

                case .thread(let uri):
                    showingThreadURI = uri
                }
            })
        }
    }

    var body: some View {
        ContentView(interacted: $interacted, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, timelineViewModel: timelineViewModel, showingToolbar: showingToolbar, verticalLayout: verticalLayout)
            .navigationDestination(item: $showingProfileHandle) { profileHandle in
                PoastProfileView(profileViewModel: PoastProfileViewModel(handle: profileHandle))
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
                                interacted: $interacted)
            }
        .task {
            if let session = user.session {
                if(await timelineViewModel.getTimeline(session: session, cursor: Date()) == nil) {
                    interacted = Date()
                }
            }
        }
    }
}

//#Preview {
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
//    let user = PoastUser(session: session)
//
//    return PoastTimelineView(timelineViewModel: PoastFeedTimelineViewModel(algorithm: ""))
//        .environmentObject(user)
//}
