//
//  FeedPostView.swift
//  Poast
//
//  Created by Christopher Head on 10/31/24.
//

import SwiftUI

struct FeedPostView: View {
    var feedViewModel: FeedViewModel

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?
    @Binding var interacted: Date

    var post: FeedFeedViewPostModel

    var body: some View {
        if let parent = post.parent {
            switch(parent) {
            case .post(let parentPost):
                PostView(postViewModel: PostViewModel(post: parentPost),
                              showingProfileHandle: $showingProfileHandle,
                              showingThreadURI: $showingThreadURI,
                              interacted: $interacted,
                              isParent: true)
                .listRowSeparator(.hidden)

            case .reference(_):
                Text("Reference")

            case .notFound(_):
                Text("Post not found")

            case .blocked(_, _):
                Text("Blocked post")
            }
        }

        PostView(postViewModel: PostViewModel(post: post),
                      showingProfileHandle: $showingProfileHandle,
                      showingThreadURI: $showingThreadURI,
                      interacted: $interacted,
                      isParent: false)
        .onAppear {
            Task {
                if feedViewModel.posts.lastIndex(of: post) == feedViewModel.posts.count - 1 {
                    _ = await feedViewModel.updatePosts(cursor: post.date)
                }
            }
        }
    }
}
