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

    @State var selectedPost: PoastPostModel? = nil

    var body: some View {
        List {
            if let threadPost = threadViewModel.threadPost {
                PoastPostView(postViewModel: PoastPostViewModel(post: threadPost.post),
                              postCollectionViewModel: threadViewModel,
                              selectedPost: $selectedPost,
                              isParent: false)
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
