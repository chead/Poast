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

    @State var timeline: PoastTimelineModel?
    @State var showingComposerView: Bool = false

    var body: some View {
        NavigationStack {
            List(Array((timeline?.posts ?? []).enumerated()), id: \.1.id) { (index, post) in
                if let parent = post.parent {
                    switch(parent) {
                    case .post(let parentPost):
                        PoastParentPostView(postViewModel: PoastPostViewModel(), post: parentPost)
                        
                    case .notFound(_):
                        Text("Post not found")
                        
                    case .blocked(_, _):
                        Text("Blocked post")
                    }
                }
                
                PoastPostView(postViewModel: PoastPostViewModel(), post: post)
                    .onAppear {
                        if index == (timeline?.posts ?? []).count - 1 {
                            print("Bottom!")
                        }
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
            .listStyle(.plain)
            .onAppear {
                Task {
                    guard let accountSession = user.accountSession else {
                        return
                    }

                    switch(await self.timelineViewModel.getTimeline(session: accountSession.session,
                                                                    cursor: nil)) {
                    case .success(let timeline):
                        self.timeline = timeline

                    case .failure(_):
                        break
                    }
                }
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

    return PoastTimelineView(timelineViewModel: PoastTimelinePreviewViewModel())
        .environmentObject(user)
}
