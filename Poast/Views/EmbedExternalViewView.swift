//
//  PostEmbedImagesViewView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI
import SwiftBluesky
import NukeUI

struct EmbedExternalViewViewView: View {
    let view: Bsky.Embed.External.View

    var body: some View {
        VStack(alignment: .leading) {
            if let thumb = view.external.thumb {
                LazyImage(url: URL(string: thumb)) { state in
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

            Link(view.external.description, destination: URL(string: view.external.uri)!)
                .buttonStyle(.plain)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(.gray, lineWidth: 1)
        )
    }
}
