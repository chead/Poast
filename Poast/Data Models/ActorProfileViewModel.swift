//
//  ProfileViewModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftBluesky

struct ActorProfileViewModel: Hashable {
    let did: String
    let handle: String
    let displayName: String?
    let description: String?
    let avatar: String?
    let banner: String?
    let followsCount: Int?
    let followersCount: Int?
    let postsCount: Int?
    let labels: [LabelModel]?

    var name: String {
        return self.displayName ?? "@\(self.handle)"
    }

    init(did: String, handle: String, displayName: String?, desc: String?, avatar: String?, banner: String?, followsCount: Int?, followersCount: Int?, postsCount: Int?, labels: [LabelModel]?) {
        self.did = did
        self.handle = handle
        self.displayName = displayName
        self.description = desc
        self.avatar = avatar
        self.banner = banner
        self.followsCount = followsCount
        self.followersCount = followersCount
        self.postsCount = postsCount
        self.labels = labels
    }

    init(profileViewBasic: Bsky.BskyActor.ProfileViewBasic) {
        self.did = profileViewBasic.did
        self.handle = profileViewBasic.handle
        self.displayName = profileViewBasic.displayName
        self.description = nil
        self.avatar = profileViewBasic.avatar
        self.banner = nil
        self.followsCount = nil
        self.followersCount = nil
        self.postsCount = nil
        self.labels = profileViewBasic.labels?.map { LabelModel(atProtoLabel: $0) }
    }

    init(profileViewDetailed: Bsky.BskyActor.ProfileViewDetailed) {
        self.did = profileViewDetailed.did
        self.handle = profileViewDetailed.handle
        self.displayName = profileViewDetailed.displayName
        self.description = profileViewDetailed.description
        self.avatar = profileViewDetailed.avatar
        self.banner = profileViewDetailed.banner
        self.followsCount = profileViewDetailed.followsCount
        self.followersCount = profileViewDetailed.followersCount
        self.postsCount = profileViewDetailed.postsCount
        self.labels = profileViewDetailed.labels?.map { LabelModel(atProtoLabel: $0) }
    }
}
