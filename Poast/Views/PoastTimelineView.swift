//
//  PoastTimelineView.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import SwiftUI

struct PoastTimelineView: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var timelineViewModel: PoastTimelineViewModel

    @State var selectedPost: PoastPostModel? = nil

    var body: some View {
        List(Array(timelineViewModel.posts.enumerated()), id: \.1.id) { (index, post) in
            if let parent = post.parent {
                switch(parent) {
                case .post(let parentPost):
                    PoastPostView(postViewModel: PoastPostViewModel(post: parentPost),
                                  postCollectionViewModel: timelineViewModel,
                                  selectedPost: $selectedPost,
                                  isParent: true)

                case .reference(_):
                    EmptyView()

                case .notFound(_):
                    Text("Post not found")
                    
                case .blocked(_, _):
                    Text("Blocked post")
                }
            }
            
            PoastPostView(postViewModel: PoastPostViewModel(post: post), 
                          postCollectionViewModel: timelineViewModel,
                          selectedPost: $selectedPost,
                          isParent: false)
                .onAppear {
                    Task {
                        if index == timelineViewModel.posts.count - 1 {
                            if let accountSession = user.accountSession {
                                _ = await timelineViewModel.getTimeline(session: accountSession.session, cursor: post.date)
                            }
                        }
                    }
                }
        }
        .listStyle(.plain)
        .navigationDestination(item: $selectedPost, destination: { post in
            PoastThreadView(threadViewModel: PoastThreadViewModel(uri: post.uri))
        })
        .refreshable {
            if let accountSession = user.accountSession {
                timelineViewModel.clearTimeline()

                _ = await timelineViewModel.getTimeline(session: accountSession.session, cursor: Date())
            }
        }
        .task {
            if let accountSession = user.accountSession {
                _ = await timelineViewModel.getTimeline(session: accountSession.session, cursor: Date())
            }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let account = PoastAccountObject(context: managedObjectContext)

    account.uuid = UUID()
    account.created = Date()
    account.handle = "@foobar.baz"
    account.host = URL(string: "https://bsky.social")!

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = account.uuid
    session.did = ""

    let user = PoastUser()

    user.accountSession = (account: account, session: session)

    return PoastTimelineView(timelineViewModel: PoastFeedTimelineViewModel(algorithm: ""))
        .environmentObject(user)
}
