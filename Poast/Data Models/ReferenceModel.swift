//
//  ReferenceModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import SwiftATProto

struct ReferenceModel: Hashable {
    let link: String

    init(atProtoRef: ATProtoRef) {
        self.link = atProtoRef.link
    }
}
