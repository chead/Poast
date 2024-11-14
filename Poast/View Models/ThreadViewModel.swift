//
//  PoastThreadViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import Foundation
import SwiftBluesky

enum ThreadViewModelError: Error {
    case blueskyClientFeedGetPostThread(error: BlueskyClientError<Bsky.Feed.GetPostThreadError>)
    case credentialsServiceGetCredentials(error: PoastCredentialsServiceError)
}

@MainActor
class ThreadViewModel: ObservableObject {
    @Dependency internal var credentialsService: PoastCredentialsService

    @Published var threadPost: FeedThreadViewPostModel? = nil

    private let uri: String

    init(uri: String) {
        self.uri = uri
    }

    func getThread(session: SessionModel) async -> ThreadViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.getPostThread(host: session.account.host,
                                                 accessToken: credentials.accessToken,
                                                 refreshToken: credentials.refreshToken,
                                                 uri: uri)) {
            case .success(let getThreadResponse):
                if let credentials = getThreadResponse.credentials {
                    _ = self.credentialsService.updateCredentials(did: session.did,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken)
                }

                self.threadPost = FeedThreadViewPostModel(threadViewPost: getThreadResponse.body.thread)

                return nil
            case .failure(let error):
                return .blueskyClientFeedGetPostThread(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }
}
