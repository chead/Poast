//
//  PoastBlockedProfileModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftBluesky

struct PoastBlockedProfileModel: Hashable {
    let did: String

    init(blockedAuthor: Bsky.Feed.BlockedAuthor) {
        self.did = blockedAuthor.did
    }
}
