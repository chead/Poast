//
//  ThreadViewPostViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/16/24.
//

import Foundation
import SwiftBluesky

enum ThreadViewPostViewModelError: Error {
    case credentialsServiceGetCredentials(error: CredentialsServiceError)
    case blueskyClientFeedGetPostThread(error: BlueskyClientError<Bsky.Feed.GetPostThreadError>)
}

@MainActor
class ThreadViewPostViewModel: ObservableObject {
    @Dependency internal var credentialsService: CredentialsService

    @Published var threadPost: Bsky.Feed.ThreadViewPost? = nil

    private let uri: String

    init(uri: String) {
        self.uri = uri
    }

    func getPostThread(session: SessionModel) async -> ThreadViewPostViewModelError? {
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

                self.threadPost = getThreadResponse.body.thread

                return nil

            case .failure(let error):
                return .blueskyClientFeedGetPostThread(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }
}
