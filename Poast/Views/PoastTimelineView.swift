//
//  PoastTimelineView.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import SwiftUI

struct PoastTimelineView: View {
    @EnvironmentObject var user: PoastUser

    @StateObject var timelineViewModel: PoastTimelineViewModel

    @State var showingComposerView: Bool = false
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()

    var body: some View {
        NavigationStack {
            List(Array(timelineViewModel.posts.enumerated()), id: \.1.id) { (index, post) in
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
                    Button {

                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Poast")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
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
            .navigationDestination(item: $showingProfileHandle) { profileHandle in
                PoastProfileView(profileViewModel: PoastProfileViewModel(handle: profileHandle))
            }
            .navigationDestination(item: $showingThreadURI) { threadURI in
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
                                interacted: $interacted)
            }
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
//    let user = PoastUser()
//
//    user.session = session
//
//    return PoastTimelineView(timelineViewModel: PoastFeedTimelineViewModel(algorithm: ""))
//        .environmentObject(user)
//}
