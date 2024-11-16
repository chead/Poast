//
//  PostView.swift
//  Poast
//
//  Created by Christopher Head on 11/16/24.
//

import Foundation
import SwiftBluesky

extension Bsky.Feed.PostView {
    var canShare: Bool {
        !(author.labels?.contains(where: { label in
            label.val == "!no-unauthenticated"
        }) ?? true)
    }

    var shareURL: URL? {
        guard let lastURICompoenentIndex = uri.lastIndex(of: "/") else { return nil }

        return URL(string: "https://bsky.app/profile/\(author.handle)/post/\(String(uri.suffix(from: lastURICompoenentIndex).dropFirst()))")
    }
}
