//
//  PoastUserModel.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation
import SwiftBluesky

struct PoastUserModel: Hashable {
    public let did: String
    public let handle: String

    init(did: String, handle: String) {
        self.did = did
        self.handle = handle
    }

    init(blueskyActorViewBasic: BlueskyActorProfileViewBasic) {
        self.did = blueskyActorViewBasic.did
        self.handle = blueskyActorViewBasic.handle
    }
}
