//
//  ActorProfileViewDetailedViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/18/24.
//

import SwiftUI
import SwiftBluesky

enum ActorProfileViewDetailedViewModelError: Error {
    case noCredentials
    case credentialsService(error: CredentialsServiceError)
    case blueskyClient(error: BlueskyClientError<Bsky.BskyActor.GetProfilesError>)
    case unknown(error: Error)
}

@MainActor
class ProfileViewDetailedViewModel: ObservableObject {
    @Dependency private var credentialsService: CredentialsService

    @Published var profileViewDetailed: Bsky.BskyActor.ProfileViewDetailed? = nil

    let session: SessionModel
    let handle: String

    init(session: SessionModel, handle: String) {
        self.session = session
        self.handle = handle
    }

    func getProfile() async -> PoastProfileViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.BskyActor.getProfiles(host: session.account.host,
                                                    accessToken: credentials.accessToken,
                                                    refreshToken: credentials.refreshToken,
                                                    actors: [handle])) {
            case .success(let getProfilesResponse):
                if let credentials = getProfilesResponse.credentials {
                    if let error = self.credentialsService.updateCredentials(did: session.did,
                                                                             accessToken: credentials.accessToken,
                                                                             refreshToken: credentials.refreshToken) {
                        return .credentialsService(error: error)
                    }
                }

                profileViewDetailed = getProfilesResponse.body.profiles.first

                return nil

            case .failure(let error):
                return .blueskyClient(error: error)
            }
        case .failure(let error):
            return .credentialsService(error: error)
        }
    }

    func canShareProfile() -> Bool {
        !(profileViewDetailed?.labels?.contains(where: { label in
            label.val == "!no-unauthenticated"
        }) ?? true)
    }

    func profileShareURL() -> URL? {
        guard let profile = profileViewDetailed else { return nil }

        return URL(string: "https://bsky.app/profile/\(profile.handle)")
    }
}
