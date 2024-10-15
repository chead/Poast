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

        @ObservedObject var timelineViewModel: PoastTimelineViewModel

        @Binding var showingComposerView: Bool
        @Binding var showingProfileHandle: String?
        @Binding var showingThreadURI: String?
        @Binding var interacted: Date

        let showingToolbar: Bool
        let verticalLayout: PoastTimelineViewVerticalLayout

        @ViewBuilder
        var body: some View {
            switch verticalLayout {
            case .list:
                List(Array(timelineViewModel.posts.enumerated()), id: \.1.id) { (index, post) in
                    PostView(timelineViewModel: timelineViewModel, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, interacted: $interacted, post: post)
                        .onAppear {
                            Task {
                                if index == timelineViewModel.posts.count - 1 {
                                    _ = await timelineViewModel.getTimeline(cursor: post.date)
                                }
                            }
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    timelineViewModel.clearTimeline()

                    _ = await timelineViewModel.getTimeline(cursor: Date())
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
                ForEach(timelineViewModel.posts, id: \.id) { post in
                    PostView(timelineViewModel: timelineViewModel, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, interacted: $interacted, post: post)
                }
            }
        }
    }

    struct PostView: View {
        @ObservedObject var timelineViewModel: PoastTimelineViewModel

        @Binding var showingComposerView: Bool
        @Binding var showingProfileHandle: String?
        @Binding var showingThreadURI: String?
        @Binding var interacted: Date

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
        ContentView(timelineViewModel: timelineViewModel, showingComposerView: $showingComposerView, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI, interacted: $interacted, showingToolbar: showingToolbar, verticalLayout: verticalLayout)
            .navigationDestination(item: $showingProfileHandle) { profileHandle in
                if let session = user.session {
                    PoastProfileView(profileViewModel: PoastProfileViewModel(session: session, handle: profileHandle))
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
                                interacted: $interacted)
            }
        .task {
            if(await timelineViewModel.getTimeline(cursor: Date()) == nil) {
                interacted = Date()
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
