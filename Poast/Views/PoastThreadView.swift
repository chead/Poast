//
//  PoastThreadView.swift
//  Poast
//
//  Created by Christopher Head on 2/13/24.
//

import SwiftUI

struct PoastThreadView: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var threadViewModel: PoastThreadViewModel

    var body: some View {
        List {
            if let threadPost = threadViewModel.threadPost {
                PoastPostView(postViewModel: PoastPostViewModel(post: threadPost.post),
                              postCollectionViewModel: threadViewModel,
                              isParent: false)

                if let replies = threadPost.replies {
                    ForEach(replies) { reply in
                        switch(reply) {
                        case .threadPost(let childThreadPost):
                            PoastPostView(postViewModel: PoastPostViewModel(post: childThreadPost.post),
                                          postCollectionViewModel: threadViewModel,
                                          isParent: false)

                        case .notFound(_):
                            Text("Post not found.")

                        case .blocked(_):
                            Text("Post blocked.")
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }.task {
            if let accountSession = user.accountSession {
                _ = await threadViewModel.getThread(session: accountSession.session)
            }
        }
    }
}

#Preview {
    PoastThreadView(threadViewModel: PoastThreadViewModel(uri: ""))
}
