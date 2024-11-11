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

enum PoastFeedViewModelError: Error {
    case noCredentials
    case blueskyClientFeedGetTimelineFeed(error: BlueskyClientError<Bsky.Feed.GetTimelineError>)
    case blueskyClientFeedGetAuthorFeed(error: BlueskyClientError<Bsky.Feed.GetAuthorFeedError>)
    case blueskyClientFeedGetActorLikesFeed(error: BlueskyClientError<Bsky.Feed.GetActorLikesError>)
    case credentialsServiceGetCredentials(error: PoastCredentialsServiceError)
    case unknown(error: Error)
}

@MainActor
class PoastFeedViewModel: ObservableObject {
    @Dependency internal var credentialsService: PoastCredentialsService

    @Published var posts: [PoastVisiblePostModel] = []

    let session: PoastSessionModel
    
    private let modelContext: ModelContext

    init(session: PoastSessionModel, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }

    func removePosts() {
        posts.removeAll()

        try? modelContext.delete(model: PoastPostLikeInteractionModel.self)
        try? modelContext.delete(model: PoastPostRepostInteractionModel.self)
        try? modelContext.delete(model: PoastThreadMuteInteractionModel.self)
    }

    func getPosts(cursor: Date) async -> Result<[PoastVisiblePostModel], PoastFeedViewModelError> {
        return .success([])
    }

    func refreshPosts() async -> PoastFeedViewModelError? {
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

    func updatePosts(cursor: Date) async -> PoastFeedViewModelError? {
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
