//
//  PoastProfileModel.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import Foundation
import SwiftBluesky

struct PoastProfileModel: Hashable {
    let did: String
    let handle: String
    let displayName: String?
    let description: String?
    let avatar: String?
    let banner: String?
    let followsCount: Int?
    let followersCount: Int?
    let postsCount: Int?
    let labels: [PoastLabelModel]?

    static func == (lhs: PoastProfileModel, rhs: PoastProfileModel) -> Bool {
        lhs.did == rhs.did
    }

    var name: String {
        return self.displayName ?? "@\(self.handle)"
    }

    init(did: String, handle: String, displayName: String, description: String, avatar: String, banner: String, followsCount: Int, followersCount: Int, postsCount: Int, labels: [PoastLabelModel]) {
        self.did = did
        self.handle = handle
        self.displayName = displayName
        self.description = description
        self.avatar = avatar
        self.banner = banner
        self.followsCount = followsCount
        self.followersCount = followersCount
        self.postsCount = postsCount
        self.labels = labels
    }
    
    init(blueskyActorProfileViewBasic: BlueskyActorProfileViewBasic) {
        self.did = blueskyActorProfileViewBasic.did
        self.handle = blueskyActorProfileViewBasic.handle
        self.displayName = blueskyActorProfileViewBasic.displayName
        self.description = nil
        self.avatar = blueskyActorProfileViewBasic.avatar
        self.banner = nil
        self.followsCount = nil
        self.followersCount = nil
        self.postsCount = nil
        self.labels = blueskyActorProfileViewBasic.labels?.map { PoastLabelModel(atProtoLabel: $0) }
    }

    init(blueskyActorProfileViewDetailed: BlueskyActorProfileViewDetailed) {
        self.did = blueskyActorProfileViewDetailed.did
        self.handle = blueskyActorProfileViewDetailed.handle
        self.displayName = blueskyActorProfileViewDetailed.displayName
        self.description = blueskyActorProfileViewDetailed.description
        self.avatar = blueskyActorProfileViewDetailed.avatar
        self.banner = blueskyActorProfileViewDetailed.banner
        self.followsCount = blueskyActorProfileViewDetailed.followsCount
        self.followersCount = blueskyActorProfileViewDetailed.followersCount
        self.postsCount = blueskyActorProfileViewDetailed.postsCount
        self.labels = blueskyActorProfileViewDetailed.labels?.map { PoastLabelModel(atProtoLabel: $0) }
    }
}
