//
//  PoastTimelineView.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import SwiftUI

struct PoastTimelineView: View {
    @EnvironmentObject var user: PoastUser

    let timelineViewModel: PoastTimelineViewModeling

    @State var posts: [PoastPostModel] = []

    var body: some View {
        List(Array(posts.enumerated()), id: \.1.id) { (index, post) in
            if let parent = post.parent {
                switch(parent) {
                case .post(let parentPost):
                    PoastParentPostView(postViewModel: PoastPostViewModel(), post: parentPost)

                case .reference(_):
                    EmptyView()

                case .notFound(_):
                    Text("Post not found")
                    
                case .blocked(_, _):
                    Text("Blocked post")
                }
            }
            
            PoastPostView(postViewModel: PoastPostViewModel(), post: post)
                .onAppear {
                    Task {
                        if index == posts.count - 1 {
                            posts.append(contentsOf: await loadContent(cursor: post.date))
                        }
                    }
                }
        }
        .listStyle(.plain)
        .refreshable {
            posts = await loadContent(cursor: Date())
        }
        .onAppear {
            Task {
                posts = await loadContent(cursor: Date())
            }
        }
    }

    func loadContent(cursor: Date) async -> [PoastPostModel] {
        guard let accountSession = user.accountSession else {
            return []
        }

        switch(await self.timelineViewModel.getTimeline(session: accountSession.session,
                                                        cursor: cursor)) {
        case .success(let timeline):
            return timeline.posts

        case .failure(_):
            return []
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

    return PoastTimelineView(timelineViewModel: PoastTimelinePreviewViewModel())
        .environmentObject(user)
}
