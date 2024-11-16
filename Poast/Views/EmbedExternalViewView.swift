//
//  PostEmbedImagesViewView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI
import SwiftBluesky

struct EmbedExternalViewViewView: View {
    let view: Bsky.Embed.External.View

    var body: some View {
        VStack(alignment: .leading) {
            if let thumb = view.external.thumb {
                AsyncImage(url: URL(string: thumb)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(.gray)
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
