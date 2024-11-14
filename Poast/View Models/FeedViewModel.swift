//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/10/24.
//

import Foundation
import SwiftData
import SwiftATProto
import SwiftBluesky

enum FeedViewModelError: Error {
    case followingFeed(error: BlueskyClientError<Bsky.Feed.GetTimelineError>)
    case authorFeed(error: BlueskyClientError<Bsky.Feed.GetAuthorFeedError>)
    case actorLikesFeed(error: BlueskyClientError<Bsky.Feed.GetActorLikesError>)
    case credentialsService(error: PoastCredentialsServiceError)
}

@MainActor
class FeedViewModel: ObservableObject {
    @Dependency internal var credentialsService: PoastCredentialsService

    @Published var posts: [FeedFeedViewPostModel] = []

    let session: SessionModel
    
    private let modelContext: ModelContext

    init(session: SessionModel, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }

    func removePosts() {
        posts.removeAll()

        try? modelContext.delete(model: LikeInteractionModel.self)
        try? modelContext.delete(model: RepostInteractionModel.self)
        try? modelContext.delete(model: MuteInteractionModel.self)
    }

    func getPosts(cursor: Date) async -> Result<[FeedFeedViewPostModel], FeedViewModelError> {
        return .success([])
    }

    func refreshPosts() async -> FeedViewModelError? {
        switch(await getPosts(cursor: Date())) {
        case .success(let newPosts):
            guard let firstNewPost = newPosts.first else {
                return nil
            }

            if(posts.first != firstNewPost) {
                posts = newPosts
            }

            return nil

        case .failure(let error):
            return error
        }
    }

    func updatePosts(cursor: Date) async -> FeedViewModelError? {
        switch(await getPosts(cursor: cursor)) {
        case .success(let newPosts):
            removePosts()

            posts.append(contentsOf: newPosts)

            return nil

        case .failure(let error):
            return error
        }
    }
}
