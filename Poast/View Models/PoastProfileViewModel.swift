//
//  PoastProfileViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import Foundation
import SwiftBluesky

enum PoastProfileViewModelError: Error {
    case session
    case profile
    case authorization
    case availability
    case request
    case service
    case unknown
}

@MainActor class PoastProfileViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var blueskyClient: BlueskyClient

    @Published var profile: PoastProfileModel? = nil

    let handle: String

    init(handle: String) {
        self.handle = handle
    }

    func getProfile(session: PoastSessionModel) async -> PoastProfileViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .unknown
            }

            do {
                switch(try await self.blueskyClient.getProfiles(host: session.account.host, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actors: [handle])) {
                case .success(let getProfilesResponse):
                    if let credentials = getProfilesResponse.credentials {
                        _ = self.credentialsService.updateCredentials(did: session.did,
                                                                      accessToken: credentials.accessToken,
                                                                      refreshToken: credentials.refreshToken)
                    }

                    profile = getProfilesResponse.body.profiles.map { PoastProfileModel(blueskyActorProfileViewDetailed: $0) }.first

                case .failure(_):
                    return .unknown
                }
            } catch(_) {
                return .unknown
            }

        case .failure(_):
            return .unknown
        }

        return .unknown
    }
}
