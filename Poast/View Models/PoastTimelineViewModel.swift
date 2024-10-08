//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/10/24.
//

import Foundation
import SwiftATProto
import SwiftBluesky

enum PoastTimelineViewModelError: Error {
    case session
    case unknown
}

@MainActor class PoastTimelineViewModel: ObservableObject {
    @Dependency internal var credentialsService: PoastCredentialsService
    @Dependency internal var accountService: PoastAccountService
    @Dependency internal var blueskyClient: BlueskyClient

    @Published var posts: [PoastPostModel] = []

    func replacePost(post: PoastPostModel, with: PoastPostModel) {}

    func clearTimeline() {
        posts.removeAll()
    }

    func getTimeline(session: PoastSessionObject, cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }
}
