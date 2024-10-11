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
    @Dependency internal var blueskyClient: BlueskyClient

    @Published var posts: [PoastVisiblePostModel] = []

    func clearTimeline() {
        posts.removeAll()
    }

    func getTimeline(session: PoastSessionModel, cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }
}
