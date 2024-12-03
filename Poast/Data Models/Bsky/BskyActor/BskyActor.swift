//
//  BskyActor.swift
//  Poast
//
//  Created by Christopher Head on 11/17/24.
//

import SwiftBluesky

extension Bsky.BskyActor.ProfileViewBasic {
    var name: String {
        return self.displayName ?? "@\(self.handle)"
    }
}
