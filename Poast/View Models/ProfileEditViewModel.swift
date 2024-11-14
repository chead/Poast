//
//  PoastProfileEditViewModel.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import Foundation
import SwiftBluesky
import SwiftATProto

enum ProfileEditViewModelError: Error {
    case credentialsService(error: PoastCredentialsServiceError)
    case getProfileFailed
    case unknown
}

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService

    @Published var profile: ActorProfileViewModel?

    private var handle: String

    init(handle: String) {
        self.handle = handle
    }

    func getProfile(session: SessionModel) async -> ProfileEditViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.BskyActor.getProfile(host: session.account.host,
                                                   accessToken: credentials.accessToken,
                                                   refreshToken: credentials.refreshToken,
                                                   actor: handle)) {
            case .success(let getProfileResponse):
                if let credentials = getProfileResponse.credentials {
                    _ = credentialsService.updateCredentials(did: session.did,
                                                             accessToken: credentials.accessToken,
                                                             refreshToken: credentials.refreshToken)
                }

                profile = ActorProfileViewModel(profileViewDetailed: getProfileResponse.body)

                return nil

            case .failure(let error):
                return .getProfileFailed
            }

        case .failure(let error):
            return .credentialsService(error: error)
        }
    }

    func putProfile(session: SessionModel) async -> ProfileEditViewModelError? {
//        guard let profile = profile else { return .unknown }

//        switch(credentialsService.getCredentials(sessionDID: session.did)) {
//        case .success(let credentials):
//            guard let credentials = credentials else {
//                return .noCredentials
//            }
//
//
//        }

//        switch(credentialsService.getCredentials(sessionDID: session.did)) {
//        case .success(let credentials):
//            guard let credentials = credentials else {
//                return .credentials
//            }
//
//            do {
//                switch(try await Bsky.BskyActor.putProfile(host: session.account.host,
//                                                           accessToken: credentials.accessToken,
//                                                           refreshToken: credentials.refreshToken,
//                                                           repo: session.did,
//                                                           profile: profile.immutableCopy())) {
//                case .success(let putProfileResponse):
//                    if let credentials = putProfileResponse.credentials {
//                        _ = credentialsService.updateCredentials(did: session.did,
//                                                                 accessToken: credentials.accessToken,
//                                                                 refreshToken: credentials.refreshToken)
//                    }
//
//                    return nil
//
//                case .failure(_):
//                    return .unknown
//                }
//            } catch {
//                return .unknown
//            }
//
//        case .failure(_):
//            return .unknown
//        }

        return nil
    }
}
