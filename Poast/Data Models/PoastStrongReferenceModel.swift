//
//  PoastStrongReferenceModel.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import Foundation
import SwiftATProto

struct PoastStrongReferenceModel: Hashable {
    let uri: String
    let cid: String

    init(atProtoRepoStrongRef: ATProtoRepoStrongRef) {
        self.uri = atProtoRepoStrongRef.uri
        self.cid = atProtoRepoStrongRef.cid
    }
}
