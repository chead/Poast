//
//  EmbedRecord.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import Foundation
import SwiftBluesky

extension Bsky.Embed.Record.ViewRecord.EmbedType: @retroactive Identifiable {
    public var id: Self { self }
}

extension Bsky.Embed.Record.ViewRecord {
    var timeAgoString: String {
        guard indexedAt.timeIntervalSinceNow.rounded() != 0 else { return "now" }

        let formatter = RelativeDateTimeFormatter()

        formatter.unitsStyle = .full

        return formatter.localizedString(for: indexedAt, relativeTo: Date())
    }
}
