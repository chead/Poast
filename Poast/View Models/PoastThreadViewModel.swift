//
//  PoastThreadViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/11/24.
//

import Foundation
import SwiftBluesky

@MainActor class PoastThreadViewModel: ObservableObject, PoastPostCollectionHosting {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

    @Published var threadPost: PoastThreadPostModel? = nil

    let uri: String

    init(uri: String) {
        self.uri = uri
    }

    func replacePost(post: PoastPostModel, with: PoastPostModel) async {}

    func getThread(session: PoastSessionObject) async -> PoastTimelineViewModelError? {
        do {
            guard session.did != nil,
                  session.accountUUID != nil
            else {
                return .session
            }

            switch(self.credentialsService.getCredentials(sessionDID: session.did!)) {
            case .success(let credentials):
                guard let credentials = credentials else {
                    return .unknown
                }

                switch(self.accountService.getAccount(uuid: session.accountUUID!)) {
                case .success(let account):
                    guard let account = account else {
                        return .unknown
                    }

                    switch(try await self.blueskyClient.getPostThread(host: account.host!, 
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken,
                                                                      uri: uri)) {
                    case .success(let getThreadResponse):
                        if let credentials = getThreadResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
                                                                          accessToken: credentials.accessToken,
                                                                          refreshToken: credentials.refreshToken)
                        }

                        threadPost = PoastThreadPostModel(blueskyFeedThreadViewPost: getThreadResponse.body.thread)

                    case .failure(_):
                        return .unknown
                    }

                case .failure(_):
                    return .unknown
                }

            case .failure(_):
                return .unknown
            }

        } catch(_) {
            return .unknown
        }

        return nil
    }
}
