//
//  ImageBlobModel.swift
//  Poast
//
//  Created by Christopher Head on 2/3/24.
//

import SwiftATProto

struct ImageBlobModel: Hashable {
    let cid: String
    let mimeType: String

    init(atProtoImageBlob: ATProtoImageBlob) {
        self.cid = atProtoImageBlob.cid
        self.mimeType = atProtoImageBlob.mimeType
    }
}
