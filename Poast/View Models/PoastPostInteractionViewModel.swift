//
//  PoastPostInteractionViewModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import Foundation
import SwiftUI
import SwiftData
import SwiftBluesky
import SwiftATProto

enum PoastPostInteractionViewModelError: Error {
    case unknown
}

@MainActor class PoastPostInteractionViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService
    @Dependency private var blueskyClient: BlueskyClient

    @EnvironmentObject var user: PoastUser

    private var modelContext: ModelContext

    let post: PoastVisiblePostModel

    @Published var likeInteraction: PoastPostLikeInteractionModel? = nil

    init(modelContext: ModelContext, post: PoastVisiblePostModel) {
        self.modelContext = modelContext
        self.post = post

        getLikeInteraction()

    }

    func getLikeInteraction() {
        let postUri = post.uri

        let likeInteractionsDescriptor = FetchDescriptor<PoastPostLikeInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let likeInteractions = try? modelContext.fetch(likeInteractionsDescriptor)

        likeInteraction = likeInteractions?.first
    }

    func createLikeInteraction(interaction: PoastPostLikeModel) {
        if let likeInteraction = likeInteraction {
            modelContext.delete(likeInteraction)
        }

        let likeInteraction = PoastPostLikeInteractionModel(postUri: post.uri, interaction: interaction)

        modelContext.insert(likeInteraction)

        do {
            try modelContext.save()

            self.likeInteraction = likeInteraction
        } catch {}
    }

    func deleteLikeInteraction(likeInteraction: PoastPostLikeInteractionModel) {
        modelContext.delete(likeInteraction)

        do {
            try modelContext.save()

            self.likeInteraction = nil
        } catch {}
    }

    func getLikeCount() -> Int {
        switch((post.like, likeInteraction?.interaction)) {
        case (.none, .some(let likeInteraction)) where likeInteraction == .liked,
             (.some, .some(let likeInteraction)) where likeInteraction == .unliked:
            return post.likeCount + likeInteraction.rawValue

        default:
            return post.likeCount
        }
    }

    func isLiked() -> Bool {
        switch((post.like, likeInteraction?.interaction)) {
        case(.some, .none):
            return true

        case (.none, .some(let likeInteraction)) where likeInteraction == .liked:
            return true

        default:
            return false
        }
    }

    func likePost(session: PoastSessionModel, uri: String, cid: String) async -> PoastPostViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
            }

            do {
                switch(try await blueskyClient.createLike(host: session.account.host,
                                                          accessToken: credentials.accessToken,
                                                          refreshToken: credentials.refreshToken,
                                                          repo: session.did,
                                                          uri: uri,
                                                          cid: cid)) {
                case .success(let createLikeResponse):
                    if let credentials = createLikeResponse.credentials {
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

    func unlikePost(session: PoastSessionModel, uri: String) async -> PoastPostViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
            }

            let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

            do {
                if(try await blueskyClient.deleteLike(host: session.account.host,
                                                      accessToken: credentials.accessToken,
                                                      refreshToken: credentials.refreshToken,
                                                      repo: session.did,
                                                      rkey: String(rkey)) != nil) {
                    return .unknown
                } else {
                    return nil
                }
            } catch {
                return .unknown
            }

        case .failure:
            return .unknown
        }
    }

    func toggleLikePost(session: PoastSessionModel) async {
        switch((likeInteraction, post.like)) {
        case (.some(let likeInteraction), _):
            deleteLikeInteraction(likeInteraction: likeInteraction)

        case(nil, .some(_)):
            if(await unlikePost(session: session, uri: post.uri) == nil) {
                createLikeInteraction(interaction: .unliked)
            }

        case(nil, nil):
            if(await likePost(session: session, uri: post.uri, cid: post.cid) == nil) {
                createLikeInteraction(interaction: .liked)
            }
        }
    }

    func repostPost(session: PoastSessionModel, uri: String, cid: String) async -> Result<ATProtoRepoStrongRef, PoastPostViewModelError> {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .failure(.credentials)
            }

            do {
                switch(try await blueskyClient.createRepost(host: session.account.host,
                                                            accessToken: credentials.accessToken,
                                                            refreshToken: credentials.refreshToken,
                                                            repo: session.did,
                                                            uri: uri,
                                                            cid: cid)) {
                case .success(let createLikeResponse):
                    if let credentials = createLikeResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return .success(ATProtoRepoStrongRef(uri: createLikeResponse.body.uri,
                                                         cid: createLikeResponse.body.cid))

                case .failure(_):
                    return .failure(.unknown)
                }
            } catch {
                return .failure(.unknown)
            }

        case .failure(_):
            return .failure(.unknown)
        }
    }

    func unrepostPost(session: PoastSessionModel, uri: String) async -> PoastPostViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
            }

            let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

            do {
                if(try await blueskyClient.deleteRepost(host: session.account.host,
                                                        accessToken: credentials.accessToken,
                                                        refreshToken: credentials.refreshToken,
                                                        repo: session.did,
                                                        rkey: String(rkey)) != nil) {
                    return .unknown
                } else {
                    return nil
                }
            } catch {
                return .unknown
            }

        case .failure:
            return .unknown
        }
    }

    func toggleRepostPost(session: PoastSessionModel) async {}
}
