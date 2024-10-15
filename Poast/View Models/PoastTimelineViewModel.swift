//
//  PoastTimelineViewModel.swift
//  Poast
//
//  Created by Christopher Head on 2/10/24.
//

import Foundation
import SwiftData
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

    let session: PoastSessionModel

    private var modelContext: ModelContext

    init(session: PoastSessionModel, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }

    func clearTimeline() {
        posts.removeAll()

        try? modelContext.delete(model: PoastPostLikeInteractionModel.self)
    }

    func getTimeline(cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }
}
