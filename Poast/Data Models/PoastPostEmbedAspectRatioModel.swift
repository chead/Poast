//
//  PoastPostEmbedAspectRatioModel.swift
//  Poast
//
//  Created by Christopher Head on 9/22/24.
//

import Foundation
import SwiftBluesky

struct PoastPostEmbedAspectRatioModel: Hashable {
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init(aspectRatio: Bsky.Embed.AspectRatio) {
        self.width = aspectRatio.width
        self.height = aspectRatio.height
    }
}
