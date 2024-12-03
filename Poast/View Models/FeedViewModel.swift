//
//  TimelineViewModel.swift
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
    case credentialsService(error: CredentialsServiceError)
}

class FeedViewModel: ObservableObject {
    @Dependency internal var credentialsService: CredentialsService

    @Published var posts: [Bsky.Feed.FeedViewPost] = []

    let session: SessionModel
    
    private let modelContext: ModelContext

    init(session: SessionModel, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }

    @MainActor
    func removePosts() {
        posts.removeAll()

        try? modelContext.delete(model: LikeInteractionModel.self)
        try? modelContext.delete(model: RepostInteractionModel.self)
        try? modelContext.delete(model: MuteInteractionModel.self)
    }

    @MainActor
    func getPosts(cursor: Date) async -> Result<[Bsky.Feed.FeedViewPost], FeedViewModelError> {
        return .success([])
    }

    @MainActor
    func refreshPosts() async -> FeedViewModelError? {
        switch(await getPosts(cursor: Date())) {
        case .success(let newPosts):
            if(posts.first != newPosts.first) {
                posts = newPosts
            }

            return nil

        case .failure(let error):
            return error
        }
    }

    @MainActor
    func updatePosts(cursor: Date) async -> FeedViewModelError? {
        switch(await getPosts(cursor: cursor)) {
        case .success(let newPosts):
            posts.append(contentsOf: newPosts)

            return nil

        case .failure(let error):
            return error
        }
    }
}
