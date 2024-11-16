//
//  EmbedRecord.swift
//  Poast
//
//  Created by Christopher Head on 11/15/24.
//

import SwiftBluesky

extension Bsky.Embed.Record.ViewDetached: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.ViewDetached, rhs: Bsky.Embed.Record.ViewDetached) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Embed.Record.ViewDetached: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Embed.Record.ViewBlocked: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.ViewBlocked, rhs: Bsky.Embed.Record.ViewBlocked) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Embed.Record.ViewBlocked: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Embed.Record.ViewNotFound: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.ViewNotFound, rhs: Bsky.Embed.Record.ViewNotFound) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Embed.Record.ViewNotFound: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Embed.Record.ViewRecord: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.ViewRecord, rhs: Bsky.Embed.Record.ViewRecord) -> Bool {
        lhs.uri == rhs.uri
    }
}

extension Bsky.Embed.Record.ViewRecord: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }
}

extension Bsky.Embed.Record.View.RecordType: @retroactive Equatable {
    public static func == (lhs: Bsky.Embed.Record.View.RecordType, rhs: Bsky.Embed.Record.View.RecordType) -> Bool {
        switch((lhs, rhs)) {
        case (.recordViewRecord(let lhsViewRecord),
              .recordViewRecord(let rhsViewRecord)):
            return lhsViewRecord == rhsViewRecord

        case (.recordViewNotFound(let lhsViewNotFound),
              .recordViewNotFound(let rhsViewNotFound)):
            return lhsViewNotFound == rhsViewNotFound

        case (.recordViewBlocked(let lhsViewBlocked),
              .recordViewBlocked(let rhsViewBlocked)):
            return lhsViewBlocked == rhsViewBlocked

        case (.recordViewDetached(let lhsViewDetached),
              .recordViewDetached(let rhsViewDetached)):
            return lhsViewDetached == rhsViewDetached

        case (.feedGeneratorView(let lhsGeneratorView),
              .feedGeneratorView(let rhsGeneratorView)):
            return lhsGeneratorView == rhsGeneratorView

        case (.graphListView(let lhsListView),
              .graphListView(let rhsListView)):
            return lhsListView == rhsListView

        case (.labelerView(let lhsLabelerView),
              .labelerView(let rhsLabelerView)):
            return lhsLabelerView == rhsLabelerView

        case (.starterPackViewBasic(let lhsStarterPackViewBasic),
              .starterPackViewBasic(let rhsStarterPackViewBasic)):
            return lhsStarterPackViewBasic == rhsStarterPackViewBasic

        default:
            return false
        }
    }
}

extension Bsky.Embed.Record.View.RecordType: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch(self) {
        case .recordViewRecord(let viewRecord):
            hasher.combine(viewRecord)

        case .recordViewNotFound(let viewNotFound):
            hasher.combine(viewNotFound)

        case .recordViewBlocked(let viewBlocked):
            hasher.combine(viewBlocked)

        case .recordViewDetached(let viewDetached):
            hasher.combine(viewDetached)

        case .feedGeneratorView(let generatorView):
            hasher.combine(generatorView)

        case .graphListView(let listView):
            hasher.combine(listView)

        case .labelerView(let labelerView):
            hasher.combine(labelerView)

        case .starterPackViewBasic(let starterPackViewBasic):
            hasher.combine(starterPackViewBasic)
        }
    }
}

extension Bsky.Embed.Record.View: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.View, rhs: Bsky.Embed.Record.View) -> Bool {
        return lhs.record == rhs.record
    }
}

extension Bsky.Embed.Record.View: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
}

extension Bsky.Embed.Record.ViewRecord.EmbedType: @retroactive Equatable {
    public static func ==(lhs: Bsky.Embed.Record.ViewRecord.EmbedType, rhs: Bsky.Embed.Record.ViewRecord.EmbedType) -> Bool {
        switch((lhs, rhs)) {
        case (.imagesView(let lhsView),
              .imagesView(let rhsView)):
            return lhsView == rhsView

        case (.externalView(let lhsView),
              .externalView(let rhsView)):
            return lhsView == rhsView

        case (.recordView(let lhsView),
              .recordView(let rhsView)):
            return lhsView == rhsView

        case (.recordWithMediaView(let lhsView),
              .recordWithMediaView(let rhsView)):
            return lhsView == rhsView

        case (.videoView(let lhsView),
              .videoView(let rhsView)):
            return lhsView == rhsView

        default:
            return false
        }
    }
}

extension Bsky.Embed.Record.ViewRecord.EmbedType: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch(self) {
        case .imagesView(let view):
            hasher.combine(view)

        case .externalView(let view):
            hasher.combine(view)

        case .recordView(let view):
            hasher.combine(view)

        case .recordWithMediaView(let view):
            hasher.combine(view)

        case .videoView(let view):
            hasher.combine(view)
        }
    }
}

extension Bsky.Embed.Record.ViewRecord.EmbedType: @retroactive Identifiable {
    public var id: Self { self }
}
