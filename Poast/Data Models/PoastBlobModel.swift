//
//  PoastBlobModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import Foundation
import SwiftATProto

struct PoastBlobModel: Hashable {
    let reference: PoastReferenceModel
    let mimeType: String
    let size: Int

    init(atProtoBlob: ATProtoBlob) {
        self.reference = PoastReferenceModel(atProtoRef: atProtoBlob.ref)
        self.mimeType = atProtoBlob.mimeType
        self.size = atProtoBlob.size
    }
}
