//
//  PoastProfileViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import Foundation

enum PoastProfileViewModelError: Error {
    case session
    case profile
    case authorization
    case availability
    case request
    case service
    case unknown

    init(blueskyServiceError: PoastBlueskyServiceError) {
        switch blueskyServiceError {
        case .clientAuthorization:
            self = .authorization

        case .clientAvailability:
            self = .availability

        case .clientRequest, .clientResponse:
            self = .request

        case .accountService, .credentialsService, .sessionService:
            self = .service

        default:
            self = .unknown
        }
    }
}

class PoastProfileViewModel: ObservableObject {
    private let blueskyService: PoastBlueskyService?
    private let session: PoastSessionObject?
    private let handle: String

    required init(provider: DependencyProviding? = nil, session: PoastSessionObject? = nil, handle: String) {
        if let provider = provider {
            self.blueskyService = provider.register(provider: provider)
        } else {
            self.blueskyService = nil
        }

        self.session = session
        self.handle = handle
    }

    func getProfile() async -> Result<PoastProfileModel?, PoastProfileViewModelError> {
        guard let session = session else {
            return .failure(.session)
        }

        guard let blueskyService = self.blueskyService else {
            return .failure(.service)
        }

        switch(await blueskyService.getProfiles(session: session, actors: [session.account!.handle!])) {
        case .success(let profileModels):
            return .success(profileModels.first)

        case .failure(_):
            return .failure(.service)
        }
    }
}
