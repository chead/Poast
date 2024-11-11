//
//  PoastProfileViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import Foundation
import SwiftBluesky

enum PoastProfileViewModelError: Error {
    case noCredentials
    case credentialsService(error: PoastCredentialsServiceError)
    case blueskyClient(error: BlueskyClientError<Bsky.BskyActor.GetProfilesError>)
    case unknown(error: Error)
}

@MainActor
class PoastProfileViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService

    @Published var profile: PoastProfileModel? = nil

    let session: PoastSessionModel
    let handle: String

    init(session: PoastSessionModel, handle: String) {
        self.session = session
        self.handle = handle
    }

    func getProfile() async -> PoastProfileViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            do {
                switch(try await Bsky.BskyActor.getProfiles(host: session.account.host, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actors: [handle])) {
                case .success(let getProfilesResponse):
                    if let credentials = getProfilesResponse.credentials {
                        if let error = self.credentialsService.updateCredentials(did: session.did,
                                                                      accessToken: credentials.accessToken,
                                                                              refreshToken: credentials.refreshToken) {
                            return .credentialsService(error: error)
                        }
                    }

                    profile = getProfilesResponse.body.profiles.map {
                        PoastProfileModel(profileViewDetailed: $0)
                    }.first

                    return nil

                case .failure(let error):
                    return .blueskyClient(error: error)
                }
            } catch(let error) {
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsService(error: error)
        }
    }

    func canShareProfile() -> Bool {
        !(profile?.labels?.contains(where: { label in
            label.val == "!no-unauthenticated"
        }) ?? true)
    }

    func profileShareURL() -> URL? {
        guard let profile = profile else { return nil }

        return URL(string: "https://bsky.app/profile/\(profile.handle)")
    }
}
