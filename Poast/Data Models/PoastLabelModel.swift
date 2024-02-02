//
//  PoastLabelModel.swift
//  Poast
//
//  Created by Christopher Head on 1/21/24.
//

import Foundation
import SwiftATProto

struct PoastLabelModel: Hashable {
    let id: String
    let val: String

    init(atProtoLabel: ATProtoLabel) {
        self.id = atProtoLabel.cid ?? ""
        self.val = atProtoLabel.val
    }
}
