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
    case noCredentials
    case credentialsServiceGetCredentials(error: PoastCredentialsServiceError)
    case blueskyClientLikePost(error: BlueskyClientError<BlueskyClient.Repo.ATProtoRepoCreateRecordError>)
    case blueskyClientUnlikePost(error: BlueskyClientError<BlueskyClient.Repo.ATProtoRepoDeleteRecordError>)
    case blueskyClientRepostPost(error: BlueskyClientError<BlueskyClient.Repo.ATProtoRepoCreateRecordError>)
    case blueskyClientUnrepostPost(error: BlueskyClientError<BlueskyClient.Repo.ATProtoRepoDeleteRecordError>)
    case blueskyClientMuteThread(error: BlueskyClientError<BlueskyClient.Graph.BlueskyGraphMuteThreadError>)
    case blueskyClientUnuteThread(error: BlueskyClientError<BlueskyClient.Graph.BlueskyGraphUnmuteThreadError>)
    case unknown(error: Error)
}

@MainActor
class PoastPostInteractionViewModel: ObservableObject {
    @Dependency private var credentialsService: PoastCredentialsService

    @EnvironmentObject var user: PoastUser

    private let modelContext: ModelContext

    let post: PoastVisiblePostModel

    @Published var likeInteraction: PoastPostLikeInteractionModel? = nil
    @Published var repostInteraction: PoastPostRepostInteractionModel? = nil
    @Published var threadMuteInteraction: PoastThreadMuteInteractionModel? = nil

    init(modelContext: ModelContext, post: PoastVisiblePostModel) {
        self.modelContext = modelContext
        self.post = post

        getInteractions()
    }

    func getInteractions() {
        getLikeInteraction()
        getRepostInteraction()
        getThreadMuteInteraction()
    }

    func toggleLikePost(session: PoastSessionModel) async {
        switch((likeInteraction, post.like)) {
        case (.some(let likeInteraction), _):
            deleteLikeInteraction(interaction: likeInteraction)

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

        self.likeInteraction = likeInteraction
    }

    private func deleteLikeInteraction(interaction: PoastPostLikeInteractionModel) {
        modelContext.delete(interaction)

        self.likeInteraction = nil
    }

    private func likePost(session: PoastSessionModel, uri: String, cid: String) async -> PoastPostInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            do {
                switch(try await BlueskyClient.Feed.createLike(host: session.account.host,
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

                case .failure(let error):
                    return .blueskyClientLikePost(error: error)
                }
            } catch(let error) {
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    func toggleRepostPost(session: PoastSessionModel) async {
        switch((repostInteraction, post.repost)) {
        case (.some(let repostInteraction), _):
            deleteRepostInteraction(interaction: repostInteraction)

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

    private func unlikePost(session: PoastSessionModel, uri: String) async -> PoastPostInteractionViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            let rkey = String(uri.split(separator: ":").last?.split(separator: "/").last ?? "")

            do {
                switch(try await BlueskyClient.Feed.deleteLike(host: session.account.host,
                                                               accessToken: credentials.accessToken,
                                                               refreshToken: credentials.refreshToken,
                                                               repo: session.did,
                                                               rkey: rkey)) {
                case .success(let deleteLikeReponse):
                    if let credentials = deleteLikeReponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return nil

                case .failure(let error):
                    return .blueskyClientUnlikePost(error: error)
                }
            } catch(let error) {
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
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

        self.repostInteraction = repostInteraction
    }

    private func deleteRepostInteraction(interaction: PoastPostRepostInteractionModel) {
        modelContext.delete(interaction)

        self.repostInteraction = nil
    }

    private func repostPost(session: PoastSessionModel, uri: String, cid: String) async -> PoastPostInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            do {
                switch(try await BlueskyClient.Feed.createRepost(host: session.account.host,
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

                case .failure(let error):
                    return .blueskyClientRepostPost(error: error)
                }
            } catch(let error) {
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    private func unrepostPost(session: PoastSessionModel, uri: String) async -> PoastPostInteractionViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

            do {
                switch(try await BlueskyClient.Feed.deleteRepost(host: session.account.host,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken,
                                                                 repo: session.did,
                                                                 rkey: String(rkey))) {

                case .success(let unrepostPostResponse):
                    if let credentials = unrepostPostResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return nil

                case .failure(let error):
                    return .blueskyClientUnrepostPost(error: error)
                }
            } catch(let error) {
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    func toggleMutePost(session: PoastSessionModel) async {
        switch((threadMuteInteraction, post.threadMuted)) {
        case (.some(let threadMuteInteraction), _):
            deleteThreadMuteInteraction(interaction: threadMuteInteraction)

        case(nil, true):
            if(await unmuteThread(session: session, uri: post.uri) == nil) {
                createThreadMuteInteraction(interaction: .unmuted)
            }

        case(nil, false):
            if(await muteThread(session: session, uri: post.uri) == nil) {
                createThreadMuteInteraction(interaction: .muted)
            }
        }
    }

    func isThreadMuted() -> Bool {
        switch((post.threadMuted, threadMuteInteraction?.interaction)) {
        case(true, .none):
            return true

        case (_, .some(let threadMuteInteraction)) where threadMuteInteraction == .muted:
            return true

        case (_, .some(let threadMuteInteraction)) where threadMuteInteraction == .unmuted:
            return false

        default:
            return false
        }
    }

    private func getThreadMuteInteraction() {
        let postUri = post.uri

        let threadMuteInteractionsDescriptor = FetchDescriptor<PoastThreadMuteInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let threadMuteInteractions = try? modelContext.fetch(threadMuteInteractionsDescriptor)

        threadMuteInteraction = threadMuteInteractions?.first
    }

    private func createThreadMuteInteraction(interaction: PoastThreadMuteModel) {
        if let threadMuteInteraction = threadMuteInteraction {
            modelContext.delete(threadMuteInteraction)
        }

        let threadMuteInteraction = PoastThreadMuteInteractionModel(postUri: post.uri, interaction: interaction)

        modelContext.insert(threadMuteInteraction)

        self.threadMuteInteraction = threadMuteInteraction
    }

    private func deleteThreadMuteInteraction(interaction: PoastThreadMuteInteractionModel) {
        modelContext.delete(interaction)

        self.threadMuteInteraction = nil
    }

    private func muteThread(session: PoastSessionModel, uri: String) async -> PoastPostInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            do {
                switch(try await BlueskyClient.Graph.muteThread(host: session.account.host,
                                                                accessToken: credentials.accessToken,
                                                                refreshToken: credentials.refreshToken,
                                                                root: uri)) {
                case .success(let muteThreadResponse):
                    if let credentials = muteThreadResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return nil

                case .failure(let error):
                    return .blueskyClientMuteThread(error: error)
                }
            } catch(let error){
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    private func unmuteThread(session: PoastSessionModel, uri: String) async -> PoastPostInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .noCredentials
            }

            do {
                switch(try await BlueskyClient.Graph.unmuteThread(host: session.account.host,
                                                                  accessToken: credentials.accessToken,
                                                                  refreshToken: credentials.refreshToken,
                                                                  root: uri)) {
                case .success(let unmuteThreadResponse):
                    if let credentials = unmuteThreadResponse.credentials {
                        _ = credentialsService.updateCredentials(did: session.did,
                                                                 accessToken: credentials.accessToken,
                                                                 refreshToken: credentials.refreshToken)
                    }

                    return nil

                case .failure(let error):
                    return .blueskyClientUnuteThread(error: error)
                }
            } catch(let error){
                return .unknown(error: error)
            }

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    func canSharePost() -> Bool {
        !(post.author.labels?.contains(where: { label in
            label.val == "!no-unauthenticated"
        }) ?? true)
    }

    func postShareURL() -> URL? {
        guard let lastURICompoenentIndex = post.uri.lastIndex(of: "/") else { return nil }

        return URL(string: "https://bsky.app/profile/\(post.author.handle)/post/\(String(post.uri.suffix(from: lastURICompoenentIndex).dropFirst()))")
    }
}
