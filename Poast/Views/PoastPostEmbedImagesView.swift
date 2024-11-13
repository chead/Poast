//
//  PoastPostEmbedImagesView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI

struct PoastPostEmbedImagesView: View {
    struct ImageRow: Identifiable {
        let id = UUID()
        let first: EmbedImagesViewImageModel
        let second: EmbedImagesViewImageModel?
    }

    let images: [EmbedImagesViewImageModel]

    var body: some View {
        let imageRows = images
            .enumerated()
            .map {
                return ImageRow(first: $0.element, second: images.count > $0.offset + 1 ? images[$0.offset + 1] : nil)
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
