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

    var body: some View {
        NavigationStack {
            List(Array(timelineViewModel.posts.enumerated()), id: \.1.id) { (index, post) in
                if let parent = post.parent {
                    switch(parent) {
                    case .post(let parentPost):
                        PoastPostView(postViewModel: PoastPostViewModel(post: parentPost),
                                      isParent: true,
                                      action: { action in
                            switch action {
                            case .profile(let handle):
                                showingProfileHandle = handle

                            case .thread(let uri):
                                showingThreadURI = uri
                            }
                        },
                                      interaction: { interaction in
                            await handlePostInteraction(interaction: interaction)
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
                              isParent: false,
                              action: { action in
                    switch action {
                    case .profile(let handle):
                        showingProfileHandle = handle

                    case .thread(let uri):
                        showingThreadURI = uri
                    }
                },
                              interaction: { interaction in
                    await handlePostInteraction(interaction: interaction)
                })
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
            .refreshable {
                if let accountSession = user.accountSession {
                    timelineViewModel.clearTimeline()

                    _ = await timelineViewModel.getTimeline(session: accountSession.session, cursor: Date())
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
                PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI))
            }
        }
        .task {
            if let accountSession = user.accountSession {
                _ = await timelineViewModel.getTimeline(session: accountSession.session, cursor: Date())
            }
        }
    }

    func handlePostInteraction(interaction: PoastPoastInteractionViewAction) async -> Void {
        switch interaction {
        case .like(let post):
            guard let accountSession = user.accountSession else { break }

            break

        case .repost(let post):
            guard let accountSession = user.accountSession else { break }

            break

        default:
            break
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
