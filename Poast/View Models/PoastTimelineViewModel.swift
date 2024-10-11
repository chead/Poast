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

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteInteractions() {
        try? modelContext.delete(model: PoastPostLikeInteractionModel.self)
    }

    func clearTimeline() {
        posts.removeAll()

        deleteInteractions()
    }

    func getTimeline(session: PoastSessionModel, cursor: Date) async -> PoastTimelineViewModelError? {
        return nil
    }
}
