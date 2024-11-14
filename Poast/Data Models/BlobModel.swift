//
//  BlobModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import SwiftATProto

struct BlobModel: Hashable {
    let reference: ReferenceModel
    let mimeType: String
    let size: Int

    init(atProtoBlob: ATProtoBlob) {
        self.reference = ReferenceModel(atProtoRef: atProtoBlob.ref)
        self.mimeType = atProtoBlob.mimeType
        self.size = atProtoBlob.size
    }
}
