//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/10/24.
//

import Foundation

protocol PoastPostCollectionHosting {
    func replacePost(post: PoastPostModel, with: PoastPostModel) async
}

@MainActor class PoastTimelineViewModel: ObservableObject, PoastPostCollectionHosting {
    @Published var posts: [PoastPostModel] = []

    func clearTimeline() {
        posts.removeAll()
    }

    func getTimeline(session: PoastSessionObject, cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }

    func replacePost(post: PoastPostModel, with: PoastPostModel) {
        for (index, oldPost) in posts.enumerated() {
            if(oldPost == post) {
                posts[index] = with
            } else if let oldParent = oldPost.parent {
                switch(oldParent) {
                case .post(let oldParentPost):
                    if(oldParentPost == post) {
                        let mutableOldPost = PoastMutablePost(postModel: oldPost)

                        mutableOldPost.parent = .post(with)

                        let mutatedOldPost = mutableOldPost.immutableCopy

                        replacePost(post: oldPost, with: mutatedOldPost)
                    }

                default:
                    break
                }
            }
        }
    }
}
