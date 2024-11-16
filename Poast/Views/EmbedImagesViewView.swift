//
//  PostEmbedImagesViewView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI
import SwiftBluesky

//struct EmbedImagesView: View {
//    struct ImageRow: Identifiable {
//        let id = UUID()
//        let first: Bsky.Embed.Images.Image
//        let second: Bsky.Embed.Images.Image?
//    }
//
//    let images: Bsky.Embed.Images
//
//    var body: some View {
//        let imageRows = images.images
//            .enumerated()
//            .map {
//                return ImageRow(first: $0.element, second: images.images.count > $0.offset + 1 ? images.images[$0.offset + 1] : nil)
//            }
//            .enumerated()
//            .filter { $0.offset % 2 == 0 }
//            .map { $0.element }
//
//        Grid {
//            ForEach(imageRows) { imageRow in
//                GridRow {
//                    AsyncImage(url: URL(string: imageRow.first.thumb)) { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                    } placeholder: {
//                        Rectangle()
//                            .fill(.gray)
//                    }
//                    .cornerRadius(8.0)
//
//                    if let secondImage = imageRow.second {
//                        AsyncImage(url: URL(string: secondImage.thumb)) { image in
//                            image
//                                .resizable()
//                                .scaledToFit()
//                        } placeholder: {
//                            Rectangle()
//                                .fill(.gray)
//                        }
//                        .cornerRadius(8.0)
//                    }
//                }
//            }
//        }
//        .fixedSize(horizontal: false, vertical: true)
//    }
//}

struct EmbedImagesViewView: View {
    struct ImageRow: Identifiable {
        let id = UUID()
        let first: Bsky.Embed.Images.ViewImage
        let second: Bsky.Embed.Images.ViewImage?
    }

    let view: Bsky.Embed.Images.View

    var body: some View {
        let imageRows = view.images
            .enumerated()
            .map {
                return ImageRow(first: $0.element, second: view.images.count > $0.offset + 1 ? view.images[$0.offset + 1] : nil)
            }
            .enumerated()
            .filter { $0.offset % 2 == 0 }
            .map { $0.element }

        Grid {
            ForEach(imageRows) { imageRow in
                GridRow {
                    AsyncImage(url: URL(string: imageRow.first.thumb)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(.gray)
                    }
                    .cornerRadius(8.0)

                    if let secondImage = imageRow.second {
                        AsyncImage(url: URL(string: secondImage.thumb)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Rectangle()
                                .fill(.gray)
                        }
                        .cornerRadius(8.0)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
