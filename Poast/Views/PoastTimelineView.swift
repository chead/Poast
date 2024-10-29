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

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date
    @Binding var refreshing: Bool

    var body: some View {
        ForEach(timelineViewModel.posts) { post in
            if let parent = post.parent {
                switch(parent) {
                case .post(let parentPost):
                    PoastPostView(postViewModel: PoastPostViewModel(post: parentPost),
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  isParent: true)
                    .padding()

                case .reference(_):
                    EmptyView()

                case .notFound(_):
                    Text("Post not found")

                case .blocked(_, _):
                    Text("Blocked post")
                }
            }

            PoastPostView(postViewModel: PoastPostViewModel(post: post),
                          showingProfileHandle: $showingProfileHandle,
                          showingThreadURI: $showingThreadURI,
                          interacted: $interacted,
                          isParent: false)
            .padding()
            .onAppear {
                Task {
                    if timelineViewModel.posts.lastIndex(of: post) == timelineViewModel.posts.count - 1 {
                        _ = await timelineViewModel.getTimeline(cursor: post.date)
                    }
                }
            }
        }
        .onChange(of: refreshing) { _, shouldRefresh in
            if(shouldRefresh) {
                Task.detached(priority: .background) {
                    await timelineViewModel.clearTimeline()

                    _ = await timelineViewModel.getTimeline(cursor: Date())
                }

                refreshing = false
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
