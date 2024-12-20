//
//  ProfileViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import Foundation
import SwiftBluesky

enum PoastProfileViewModelError: Error {
    case noCredentials
    case credentialsService(error: CredentialsServiceError)
    case blueskyClient(error: BlueskyClientError<Bsky.BskyActor.GetProfilesError>)
    case unknown(error: Error)
}

@MainActor
class ProfileViewViewModel: ObservableObject {
    @Dependency private var credentialsService: CredentialsService

    @Published var profile: ActorProfileViewModel? = nil

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

                profile = getProfilesResponse.body.profiles.map {
                    ActorProfileViewModel(profileViewDetailed: $0)
                }.first

                return nil

            case .failure(let error):
                return .blueskyClient(error: error)
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
