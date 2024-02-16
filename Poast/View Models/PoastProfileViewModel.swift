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
    @Dependency private var accountService: PoastAccountService
    @Dependency private var blueskyClient: BlueskyClient

    @Published var profile: PoastProfileModel? = nil

    let handle: String

    init(handle: String) {
        self.handle = handle
    }

    func getProfile(session: PoastSessionObject) async -> PoastProfileViewModelError? {
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

                do {
                    switch(try await self.blueskyClient.getProfiles(host: account.host!, accessToken: credentials.accessToken, refreshToken: credentials.refreshToken, actors: [handle])) {
                    case .success(let getProfilesResponse):
                        if let credentials = getProfilesResponse.credentials {
                            _ = self.credentialsService.updateCredentials(did: session.did!,
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

        case .failure(_):
            return .unknown
        }

        return .unknown
    }
}

//struct PoastProfileViewPreviewModel: PostProfileViewModeling {
//    let handle: String
//
//    func getProfile(session: PoastSessionObject) async -> Result<PoastProfileModel?, PoastProfileViewModelError> {
//        let managedObjectContext = PersistenceController.preview.container.viewContext
//
//        let account = PoastAccountObject(context: managedObjectContext)
//
//        account.created = Date()
//        account.handle = "Foobar"
//        account.host = URL(string: "https://bsky.social")!
//        account.uuid = UUID()
//
//        let session = PoastSessionObject(context: managedObjectContext)
//
//        session.created = Date()
//        session.accountUUID = account.uuid!
//        session.did = ""
//
//        let profile = PoastProfileModel(did: "0",
//                                        handle: "foobar",
//                                        displayName: "FOOBAR",
//                                        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a tortor dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean a felis sit amet elit viverra porttitor. In hac habitasse platea dictumst. Nulla mollis luctus sagittis. Vestibulum volutpat ipsum vel elit accumsan dapibus. Vivamus quis erat consequat, auctor est id, malesuada sem.",
//                                        avatar: "",
//                                        banner: "",
//                                        followsCount: 0,
//                                        followersCount: 1,
//                                        postsCount: 2,
//                                        labels: [])
//
//        return .success(profile)
//    }
//}
