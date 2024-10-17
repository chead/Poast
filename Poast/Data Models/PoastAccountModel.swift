//
//  PoastAccountModel.swift
//  Poast
//
//  Created by Christopher Head on 10/8/24.
//

import Foundation
import SwiftData

@Model
class PoastAccountModel: Codable {
    private enum CodingKeys: CodingKey {
        case uuid
        case created
        case handle
        case host
        case session
    }

    @Attribute(.unique)
    var uuid: UUID
    var created: Date
    var handle: String
    var host: URL
    var handleAndHost: String { "\(handle)@\(host.absoluteString)" }
    var session: PoastSessionModel?

    init(uuid: UUID, created: Date, handle: String, host: URL, session: PoastSessionModel?) {
        self.uuid = uuid
        self.created = created
        self.handle = handle
        self.host = host
        self.session = session
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.created = try container.decode(Date.self, forKey: .created)
        self.handle = try container.decode(String.self, forKey: .handle)
        self.host = try container.decode(URL.self, forKey: .host)
        self.session = try container.decode(PoastSessionModel?.self, forKey: .session)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uuid, forKey: .uuid)
        try container.encode(created, forKey: .created)
        try container.encode(handle, forKey: .handle)
        try container.encode(host, forKey: .host)
        try container.encode(session, forKey: .session)
    }
}
