//
//  ViewModel.swift
//  Poast
//
//  Created by Christopher Head on 1/31/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum PostViewModelError: Error {
    case noCredentials
    case credentialsService(error: CredentialsServiceError)
    case blueskyClientGetPosts(error: BlueskyClientError<Bsky.Feed.GetPostsError>)
    case unknown(error: Error)
}



@MainActor
class PostViewViewModel {
    @Dependency private var credentialsService: CredentialsService

    let postView: Bsky.Feed.PostView

    init(postView: Bsky.Feed.PostView) {
        self.postView = postView
    }

    func getPost(session: SessionModel, uri: String) async -> Result<Bsky.Feed.PostView?, PostViewModelError> {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getPosts(host: session.account.host,
                                            accessToken: credentials.accessToken,
                                            refreshToken: credentials.refreshToken,
                                            uris: [uri])) {
            case .success(let getPostsResponse):
                if let credentials = getPostsResponse.credentials {
                    _ = self.credentialsService.updateCredentials(did: session.did,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken)
                }

                return .success(getPostsResponse.body.posts.first)

            case .failure(let error):
                return .failure(.blueskyClientGetPosts(error: error))
            }

        case .failure(let error):
            return .failure(.credentialsService(error: error))
        }
    }
}
