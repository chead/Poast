//
//  PoastSessionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/8/24.
//

import Foundation
import SwiftData

@Model
class PoastSessionModel: ObservableObject, Codable {
    private enum CodingKeys: CodingKey {
        case account
        case did
        case created
    }

    var account: PoastAccountModel
    @Attribute(.unique)
    var did: String
    var created: Date

    init(account: PoastAccountModel, did: String, created: Date) {
        self.account = account
        self.did = did
        self.created = created
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.account = try container.decode(PoastAccountModel.self, forKey: .account)
        self.did = try container.decode(String.self, forKey: .did)
        self.created = try container.decode(Date.self, forKey: .created)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(account, forKey: .account)
        try container.encode(did, forKey: .did)
        try container.encode(created, forKey: .created)
    }
}