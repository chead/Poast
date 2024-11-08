//
//  PoastThreadViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import Foundation
import SwiftBluesky

enum PoastThreadViewModelError: Error {
    case noCredentials
    case blueskyClientFeedGetPostThread(error: BlueskyClientError<BlueskyClient.Feed.BlueskyFeedGetPostThreadError>)
    case credentialsServiceGetCredentials(error: PoastCredentialsServiceError)
    case unknown(error: Error)
}

@MainActor
class PoastThreadViewModel: ObservableObject {
    @Dependency internal var credentialsService: PoastCredentialsService

    @Published var threadPost: PoastThreadPostModel? = nil

    private let uri: String

    init(uri: String) {
        self.uri = uri
    }

    func getThread(session: PoastSessionModel) async -> PoastThreadViewModelError? {
        do {
            switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .noCredentials
                }

                switch(try await BlueskyClient.Feed.getPostThread(host: session.account.host,
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken,
                                                                      uri: uri)) {
                case .success(let getThreadResponse):
                    if let credentials = getThreadResponse.credentials {
                        _ = self.credentialsService.updateCredentials(did: session.did,
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken)
                    }
                        
                    self.threadPost = PoastThreadPostModel(blueskyFeedThreadViewPost: getThreadResponse.body.thread)

                case .failure(let error):
                    return .blueskyClientFeedGetPostThread(error: error)
                }

            case .failure(let error):
                return .credentialsServiceGetCredentials(error: error)
            }
        } catch(let error) {
            return .unknown(error: error)
        }

        return nil
    }
}
