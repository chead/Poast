//
//  PoastAddAccountViewModel.swift
//  Poast
//
//  Created by Christopher Head on 8/3/23.
//

import Foundation

enum PoastSignInViewModelError: Error {
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

class PoastSignInViewModel: ObservableObject {
    @Dependency private(set) var blueskyService: PoastBlueskyService
    
    required init() {}
    
    func signIn(host: URL, handle: String, password: String) async -> Result<PoastSessionObject, PoastSignInViewModelError> {
        switch(await self.blueskyService.createSession(host: host, handle: handle, password: password)) {
        case .success(let sessionObject):
            return .success(sessionObject)
        
        case .failure(let error):
            return .failure(PoastSignInViewModelError(blueskyServiceError: error))
        }
    }
}
