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

    @Published var interaction: PoastPostInteractionModel? = nil

    init(modelContext: ModelContext, post: PoastVisiblePostModel) {
        self.modelContext = modelContext
        self.post = post
        self.interaction = getInteraction()
    }

    func getInteraction() -> PoastPostInteractionModel? {
        let postId = post.id

        let interactionsDescriptor = FetchDescriptor<PoastPostInteractionModel>(predicate: #Predicate { interaction in
            return interaction.postId == postId
        })

        let interactions = try? modelContext.fetch(interactionsDescriptor)

        return interactions?.first
    }

    func getOrCreateInteraction() -> PoastPostInteractionModel? {
        if let interaction = getInteraction() {
            return interaction
        } else {
            let interaction = PoastPostInteractionModel(postId: post.id)

            modelContext.insert(interaction)

            if((try? modelContext.save()) != nil) {
                return interaction
            } else {
                return nil
            }
        }
    }

    func getLikeCount() -> Int {
        return post.likeCount + (getInteraction()?.like != nil ? 1 : 0)
    }

    func isLiked() -> Bool {
        return post.like != nil || interaction?.like != nil
    }

    func likePost(session: PoastSessionModel, uri: String, cid: String) async -> Result<ATProtoRepoStrongRef, PoastPostViewModelError> {
        switch(credentialsService.getCredentials(sessionDID: session.did)) {
        case .success(let credentials):
            guard let credentials = credentials else {
                return .failure(.credentials)
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
        if(post.like != nil || interaction != nil) {
            if(await unlikePost(session: session,
                                uri: post.like ?? "") == nil) {
                if let interaction = getOrCreateInteraction() {
                    interaction.like = nil
                }
            }
        } else {
            switch(await likePost(session: session,
                                  uri: post.uri,
                                  cid: post.cid)) {
            case.success:
                if let interaction = getOrCreateInteraction() {
                    let like = PoastPostLikeModel(interaction: interaction, date: Date())

                    interaction.like = like

                    try? modelContext.save()

                    if((try? modelContext.save()) != nil) {
                        self.interaction = interaction
                    }
                }

            case .failure:
                break
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

    func toggleRepostPost(session: PoastSessionModel) async {
        if(post.like != nil) {
            if(await unrepostPost(session: session,
                                  uri: post.like ?? "") == nil) {
            }
        } else {
            switch(await repostPost(session: session,
                                  uri: post.uri,
                                  cid: post.cid)) {
            case.success:
                break

            case .failure:
                break
            }
        }
    }
}
