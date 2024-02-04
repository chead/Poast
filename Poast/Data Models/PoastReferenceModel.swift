//
//  PoastReferenceModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import Foundation
import SwiftATProto

struct PoastReferenceModel: Hashable {
    let link: String

    init(atProtoRef: ATProtoRef) {
        self.link = atProtoRef.link
    }
}
