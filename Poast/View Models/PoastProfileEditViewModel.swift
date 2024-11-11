//
//  PoastProfileEditViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum PoastProfileEditViewModelError: Error {
    case credentials
    case unknown
}

class MutableBlueskyActorProfile {
    var displayName: String?
    var description: String?
    var avatar: ATProtoBlob?
    var banner: ATProtoBlob?
    var labels: ATProtoSelfLabels?
    var joinedViaStarterPack: ATProtoRepoStrongRef?
    var pinnedPost: ATProtoRepoStrongRef?
    let createdAt: Date?

    init(profile: Bsky.BskyActor.Profile) {
        self.displayName = profile.displayName
        self.description = profile.description
        self.avatar = profile.avatar
        self.banner = profile.banner
        self.labels = profile.labels
        self.joinedViaStarterPack = profile.joinedViaStarterPack
        self.pinnedPost = profile.pinnedPost
        self.createdAt = profile.createdAt
    }

    func immutableCopy() -> Bsky.BskyActor.Profile {
        Bsky.BskyActor.Profile(displayName: displayName,
                               description: description,
                               avatar: avatar,
                               banner: banner,labels: labels,
                               joinedViaStarterPack: joinedViaStarterPack,
                               pinnedPost: pinnedPost,
                               createdAt: createdAt)
    }
}

@MainActor
class PoastProfileEditViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService

    @Published var profile: MutableBlueskyActorProfile?

    private var handle: String

    init(handle: String) {
        self.handle = handle
    }

    func getProfile(session: PoastSessionModel) async -> PoastProfileEditViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
            }

            do {
                switch(try await Bsky.BskyActor.getProfile(host: session.account.host,
                                                           accessToken: credentials.accessToken,
                                                           refreshToken: credentials.refreshToken,
                                                           actor: handle)) {
                case .success(let getProfileResponse):
                    if let credentials = getProfileResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    profile = MutableBlueskyActorProfile(profile: getProfileResponse.body)

                case .failure(_):
                    return .unknown
                }
            } catch {
                return .unknown
            }

        case .failure(_):
            return .unknown
        }

        return nil
    }

    func putProfile(session: PoastSessionModel) async -> PoastProfileEditViewModelError? {
        guard let profile = profile else { return .unknown }

        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
            }

            do {
                switch(try await Bsky.BskyActor.putProfile(host: session.account.host,
                                                           accessToken: credentials.accessToken,
                                                           refreshToken: credentials.refreshToken,
                                                           repo: session.did,
                                                           profile: profile.immutableCopy())) {
                case .success(let putProfileResponse):
                    if let credentials = putProfileResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return nil

                case .failure(_):
                    return .unknown
                }
            } catch {
                return .unknown
            }

        case .failure(_):
            return .unknown
        }
    }
}
