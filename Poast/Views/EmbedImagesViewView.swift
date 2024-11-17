//
//  PostEmbedImagesViewView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI
import SwiftBluesky
import NukeUI

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
                    LazyImage(url: URL(string: imageRow.first.thumb)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .cornerRadius(8.0)

                    if let secondImage = imageRow.second {
                        LazyImage(url: URL(string: secondImage.thumb)) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .cornerRadius(8.0)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
