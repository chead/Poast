//
//  InteractionViewModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import Foundation
import SwiftUI
import SwiftData
import SwiftBluesky
import SwiftATProto

enum PostViewInteractionViewModelError: Error {
    case noCredentials
    case credentialsServiceGetCredentials(error: CredentialsServiceError)
    case blueskyClientLikePost(error: BlueskyClientError<ATProto.Repo.CreateRecordError>)
    case blueskyClientUnlikePost(error: BlueskyClientError<ATProto.Repo.DeleteRecordError>)
    case blueskyClientRepostPost(error: BlueskyClientError<ATProto.Repo.CreateRecordError>)
    case blueskyClientUnrepostPost(error: BlueskyClientError<ATProto.Repo.DeleteRecordError>)
    case blueskyClientMuteThread(error: BlueskyClientError<Bsky.Graph.MuteThreadError>)
    case blueskyClientUnuteThread(error: BlueskyClientError<Bsky.Graph.UnmuteThreadError>)
    case modelContext(error: Error)
}

@MainActor
class PostViewInteractionViewModel: ObservableObject {
    @Dependency private var credentialsService: CredentialsService

    @EnvironmentObject var user: UserModel

    private let modelContext: ModelContext

    let postView: Bsky.Feed.PostView

    @Published var likeInteraction: LikeInteractionModel? = nil
    @Published var repostInteraction: RepostInteractionModel? = nil
    @Published var threadMuteInteraction: MuteInteractionModel? = nil

    init(modelContext: ModelContext, postView: Bsky.Feed.PostView) {
        self.modelContext = modelContext
        self.postView = postView

        getInteractions()
    }

    func getInteractions() {
        getLikeInteraction()
        getRepostInteraction()
        getThreadMuteInteraction()
    }

    func toggleLikePost(session: SessionModel) async -> PostViewInteractionViewModelError? {
        switch((likeInteraction, postView.viewer?.like)) {
        case (.some(let likeInteraction), _):
            return deleteLikeInteraction(interaction: likeInteraction)

        case(.none, .some):
            if(await unlikePost(session: session, uri: postView.uri) == nil) {
                return createLikeInteraction(interaction: .unliked)
            }

        case(.none, .none):
            if(await likePost(session: session, uri: postView.uri, cid: postView.cid) == nil) {
                return createLikeInteraction(interaction: .liked)
            }
        }

        return nil
    }

    func isLiked() -> Bool {
        switch((postView.viewer?.like, likeInteraction?.interaction)) {
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
        switch((postView.viewer?.like, likeInteraction?.interaction)) {
        case (.none, .some(let likeInteraction)) where likeInteraction == .liked,
            (.some, .some(let likeInteraction)) where likeInteraction == .unliked:
            return (postView.likeCount ?? 0) + likeInteraction.rawValue

        default:
            return postView.likeCount ?? 0
        }
    }

    private func getLikeInteraction() {
        let postUri = postView.uri

        let likeInteractionsDescriptor = FetchDescriptor<LikeInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let likeInteractions = try? modelContext.fetch(likeInteractionsDescriptor)

        likeInteraction = likeInteractions?.first
    }

    private func createLikeInteraction(interaction: LikeModel) -> PostViewInteractionViewModelError? {
        if let likeInteraction = likeInteraction {
            modelContext.delete(likeInteraction)
        }

        let likeInteraction = LikeInteractionModel(postUri: postView.uri, interaction: interaction)

        modelContext.insert(likeInteraction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.likeInteraction = likeInteraction

        return nil
    }

    private func deleteLikeInteraction(interaction: LikeInteractionModel) -> PostViewInteractionViewModelError? {
        modelContext.delete(interaction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.likeInteraction = nil

        return nil
    }

    private func likePost(session: SessionModel, uri: String, cid: String) async -> PostViewInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.createLike(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    private func unlikePost(session: SessionModel, uri: String) async -> PostViewInteractionViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            let rkey = String(uri.split(separator: ":").last?.split(separator: "/").last ?? "")

            switch(await Bsky.Feed.deleteLike(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    func toggleRepostPost(session: SessionModel) async -> PostViewInteractionViewModelError? {
        switch((repostInteraction, postView.viewer?.repost)) {
        case (.some(let repostInteraction), _):
            return deleteRepostInteraction(interaction: repostInteraction)

        case(.none, .some(_)):
            if(await unrepostPost(session: session, uri: postView.uri) == nil) {
                return createRepostInteraction(interaction: .unreposted)
            }

        case(.none, .none):
            if(await repostPost(session: session, uri: postView.uri, cid: postView.cid) == nil) {
                return createRepostInteraction(interaction: .reposted)
            }
        }

        return nil
    }

    func isReposted() -> Bool {
        switch((postView.viewer?.repost, repostInteraction?.interaction)) {
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
        switch((postView.viewer?.repost, repostInteraction?.interaction)) {
        case (.none, .some(let repostInteraction)) where repostInteraction == .reposted,
            (.some, .some(let repostInteraction)) where repostInteraction == .unreposted:
            return (postView.repostCount ?? 0) + repostInteraction.rawValue

        default:
            return postView.repostCount ?? 0
        }
    }

    private func getRepostInteraction() {
        let postUri = postView.uri

        let repostInteractionsDescriptor = FetchDescriptor<RepostInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let repostInteractions = try? modelContext.fetch(repostInteractionsDescriptor)

        self.repostInteraction = repostInteractions?.first
    }

    private func createRepostInteraction(interaction: RepostModel) -> PostViewInteractionViewModelError? {
        if let repostInteraction = repostInteraction {
            modelContext.delete(repostInteraction)
        }

        let repostInteraction = RepostInteractionModel(postUri: postView.uri, interaction: interaction)

        modelContext.insert(repostInteraction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.repostInteraction = repostInteraction

        return nil
    }

    private func deleteRepostInteraction(interaction: RepostInteractionModel) -> PostViewInteractionViewModelError? {
        modelContext.delete(interaction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.repostInteraction = nil

        return nil
    }

    private func repostPost(session: SessionModel, uri: String, cid: String) async -> PostViewInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Feed.createRepost(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    private func unrepostPost(session: SessionModel, uri: String) async -> PostViewInteractionViewModelError? {
        switch(self.credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            let rkey = uri.split(separator: ":").last?.split(separator: "/").last ?? ""

            switch(await Bsky.Feed.deleteRepost(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    func toggleMutePost(session: SessionModel) async -> PostViewInteractionViewModelError? {
        switch((threadMuteInteraction, postView.viewer?.threadMuted)) {
        case (.some(let threadMuteInteraction), _):
            return deleteThreadMuteInteraction(interaction: threadMuteInteraction)

        case(.none, true):
            if(await unmuteThread(session: session, uri: postView.uri) == nil) {
                return createThreadMuteInteraction(interaction: .unmuted)
            }

        case(.none, false):
            if(await muteThread(session: session, uri: postView.uri) == nil) {
                return createThreadMuteInteraction(interaction: .muted)
            }

        case (.none, _):
            return nil
        }

        return nil
    }

    func isThreadMuted() -> Bool {
        switch((postView.viewer?.threadMuted, threadMuteInteraction?.interaction)) {
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
        let postUri = postView.uri

        let threadMuteInteractionsDescriptor = FetchDescriptor<MuteInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postUri == postUri
        })

        let threadMuteInteractions = try? modelContext.fetch(threadMuteInteractionsDescriptor)

        threadMuteInteraction = threadMuteInteractions?.first
    }

    private func createThreadMuteInteraction(interaction: MuteModel) -> PostViewInteractionViewModelError? {
        if let threadMuteInteraction = threadMuteInteraction {
            modelContext.delete(threadMuteInteraction)
        }

        let threadMuteInteraction = MuteInteractionModel(postUri: postView.uri, interaction: interaction)

        modelContext.insert(threadMuteInteraction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.threadMuteInteraction = threadMuteInteraction

        return nil
    }

    private func deleteThreadMuteInteraction(interaction: MuteInteractionModel) -> PostViewInteractionViewModelError? {
        modelContext.delete(interaction)

        do {
            try modelContext.save()
        } catch(let error) {
            return .modelContext(error: error)
        }

        self.threadMuteInteraction = nil

        return nil
    }

    private func muteThread(session: SessionModel, uri: String) async -> PostViewInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Graph.muteThread(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }

    private func unmuteThread(session: SessionModel, uri: String) async -> PostViewInteractionViewModelError? {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            switch(await Bsky.Graph.unmuteThread(host: session.account.host,
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

        case .failure(let error):
            return .credentialsServiceGetCredentials(error: error)
        }
    }
}
