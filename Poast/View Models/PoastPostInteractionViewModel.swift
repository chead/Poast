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
    @Published var repostInteraction: PoastPostRepostInteractionModel? = nil

    init(modelContext: ModelContext, post: PoastVisiblePostModel) {
        self.modelContext = modelContext
        self.post = post

        getInteractions()
    }

    func getInteractions() {
        getLikeInteraction()
        getRepostInteraction()
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

    func isLiked() -> Bool {
        switch((post.like, likeInteraction?.interaction)) {
        case(.some, .none):
            return true

        case (_, .some(let likeInteraction)) where likeInteraction == .liked:
            return true

        case (_, .some(let likeInteraction)) where likeInteraction == .unliked:
            return false

        default:
            return false
        }
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

    private func getLikeInteraction() {
        let postUri = post.uri

        let likeInteractionsDescriptor = FetchDescriptor<PoastPostLikeInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let likeInteractions = try? modelContext.fetch(likeInteractionsDescriptor)

        likeInteraction = likeInteractions?.first
    }

    private func createLikeInteraction(interaction: PoastPostLikeModel) {
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

    private func deleteLikeInteraction(likeInteraction: PoastPostLikeInteractionModel) {
        modelContext.delete(likeInteraction)

        do {
            try modelContext.save()

            self.likeInteraction = nil
        } catch {}
    }

    private func likePost(session: PoastSessionModel, uri: String, cid: String) async -> PoastPostViewModelError? {
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

    func toggleRepostPost(session: PoastSessionModel) async {
        switch((repostInteraction, post.repost)) {
        case (.some(let repostInteraction), _):
            deleteRepostInteraction(repostInteraction: repostInteraction)

        case(nil, .some(_)):
            if(await unrepostPost(session: session, uri: post.uri) == nil) {
                createRepostInteraction(interaction: .unreposted)
            }

        case(nil, nil):
            if(await repostPost(session: session, uri: post.uri, cid: post.cid) == nil) {
                createRepostInteraction(interaction: .reposted)
            }
        }
    }

    func isReposted() -> Bool {
        switch((post.repost, repostInteraction?.interaction)) {
        case(.some, .none):
            return true

        case (_, .some(let repostInteraction)) where repostInteraction == .reposted:
            return true

        case (_, .some(let repostInteraction)) where repostInteraction == .unreposted:
            return false

        default:
            return false
        }
    }

    func getRepostCount() -> Int {
        switch((post.repost, repostInteraction?.interaction)) {
        case (.none, .some(let repostInteraction)) where repostInteraction == .reposted,
             (.some, .some(let repostInteraction)) where repostInteraction == .unreposted:
            return post.repostCount + repostInteraction.rawValue

        default:
            return post.repostCount
        }
    }

    private func unlikePost(session: PoastSessionModel, uri: String) async -> PoastPostViewModelError? {
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

    private func getRepostInteraction() {
        let postUri = post.uri

        let repostInteractionsDescriptor = FetchDescriptor<PoastPostRepostInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let repostInteractions = try? modelContext.fetch(repostInteractionsDescriptor)

        self.repostInteraction = repostInteractions?.first
    }

    private func createRepostInteraction(interaction: PoastPostRepostModel) {
        if let repostInteraction = repostInteraction {
            modelContext.delete(repostInteraction)
        }

        let repostInteraction = PoastPostRepostInteractionModel(postUri: post.uri, interaction: interaction)

        modelContext.insert(repostInteraction)

        do {
            try modelContext.save()

            self.repostInteraction = repostInteraction
        } catch {}
    }

    private func deleteRepostInteraction(repostInteraction: PoastPostRepostInteractionModel) {
        modelContext.delete(repostInteraction)

        do {
            try modelContext.save()

            self.repostInteraction = nil
        } catch {}
    }

    private func repostPost(session: PoastSessionModel, uri: String, cid: String) async -> PoastPostViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .credentials
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

    private func unrepostPost(session: PoastSessionModel, uri: String) async -> PoastPostViewModelError? {
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
}
