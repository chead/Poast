//
//  ATProtoLabel.swift
//  Poast
//
//  Created by Christopher Head on 11/17/24.
//

import SwiftATProto

extension ATProtoLabel: @retroactive Equatable {
    public static func ==(lhs: ATProtoLabel, rhs: ATProtoLabel) -> Bool {
        lhs.src == rhs.src &&
        lhs.uri == rhs.uri &&
        lhs.cid == rhs.cid &&
        lhs.val == rhs.val &&
        lhs.neg == rhs.neg &&
        lhs.cts == rhs.cts
    }
}

extension ATProtoLabel: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(src)
        hasher.combine(uri)
        hasher.combine(cid)
        hasher.combine(val)
        hasher.combine(neg)
        hasher.combine(cts)
    }
}
