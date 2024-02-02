//
//  PoastEmbedModel.swift
//  Poast
//
//  Created by Christopher Head on 1/28/24.
//

import Foundation
import SwiftBluesky

struct PoastEmbedExternal {
    public let uri: String
    public let title: String
    public let description: String
    public let thumb: String?
}
struct PoastEmbedExternalView {
    public let uri: String
    public let description: String
    public let thumb: String?
}

struct PoastEmbedImage {
    public let image: String
    public let alt: String?
    public let aspectRatio: (width: Int, height: Int)?
    public let mimeType: String
}

struct PoastEmbedImageView {
}

struct PoastEmbedRecord {

}

struct PoastEmbedRecordView {

}

struct PoastEmbedRecordWithMedia {

}

struct PoastEmbedRecordWithMediaView {

}

//enum PoastEmbed {
//    case images([PoastEmbedImage])
//    case imageViews([PoastEmbedImageView])
//    case external(PoastEmbedExternal)
//    case externalView(PoastEmbedExternalView)
//    case record(PoastEmbedRecord)
//    case recordView(PoastEmbedRecordView)
//    case recordWithMedia(PoastEmbedRecordWithMedia)
//    case recordWithMediaView(PoastEmbedRecordWithMediaView)
//
//    init(blueskyEmbedType: BlueskyEmbedType) {
//        switch(blueskyEmbedType) {
//        case .blueskyEmbedExternal(let blueskyEmbedExternal):
//            let embedExternal = PoastEmbedExternal(uri: blueskyEmbedExternal.external.uri,
//                                                   title: blueskyEmbedExternal.external.title,
//                                                   description: blueskyEmbedExternal.external.description,
//                                                   thumb: blueskyEmbedExternal.external.thumb?.ref.link)
//
//            self = .external(embedExternal)
//
//        case .blueskyEmbedExternalView(let blueskyEmbedExternalView):
//            let embedExternalView = PoastEmbedExternalView(uri: blueskyEmbedExternalView.external.uri,
//                                                           description: blueskyEmbedExternalView.external.description,
//                                                           thumb: blueskyEmbedExternalView.external.thumb)
//
//            self = .externalView(embedExternalView)
//
//        case .blueskyEmbedImages(let blueskyEmbedImages):
//            let images: [PoastEmbedImage] = blueskyEmbedImages.images.map {
//                switch($0.image) {
//                case .atProtoBlob(let atProtoBlob):
//                    var aspectRatio: (Int, Int)? = nil
//
//                    if let imageAspectRatio = $0.aspectRatio {
//                        aspectRatio = (imageAspectRatio.width, imageAspectRatio.height)
//                    }
//
//                    PoastEmbedImage(image: atProtoBlob.ref.link, alt: $0.alt, aspectRatio: aspectRatio, mimeType: atProtoBlob.mimeType)
//
//                case .atProtoImageBlob(let atProtoImageBlob):
//                    PoastEmbedImage(image: atProtoImageBlob.cid, alt: nil, aspectRatio: nil, mimeType: atProtoImageBlob.mimeType)
//                }
//            }
//
//
//            self = .images(images)
//        }
//    }
//}
