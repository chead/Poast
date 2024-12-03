//
//  FeedPostView.swift
//  Poast
//
//  Created by Christopher Head on 10/31/24.
//

import SwiftUI
import SwiftBluesky

struct FeedViewPostView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?

    var feedViewPost: Bsky.Feed.FeedViewPost

    var body: some View {
        if let parent = feedViewPost.reply?.parent {
            switch(parent) {
            case .postView(let postView):
                PostViewView(postViewViewModel: PostViewViewModel(postView: postView),
                             showingProfileHandle: $showingProfileHandle,
                             showingThreadURI: $showingThreadURI,
                             isParent: true,
                             showThread: true)
                .padding()

            case .blockedPost(_):
                BlockedPostView()
                    .padding()

            case .notFoundPost(_):
                NotFoundPostView()
                    .padding()
            }
        }

        PostViewView(postViewViewModel: PostViewViewModel(postView: feedViewPost.post),
                     showingProfileHandle: $showingProfileHandle,
                     showingThreadURI: $showingThreadURI,
                     showThread: true)
        .padding()
    }
}
