//
//  PostEmbedImagesView.swift
//  Poast
//
//  Created by Christopher Head on 2/6/24.
//

import SwiftUI

struct PostEmbedExternalView: View {
    let external: EmbedExternalViewExternalModel

    var body: some View {
        VStack(alignment: .leading) {
            if let thumb = external.thumb {
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

            Link(external.description, destination: URL(string: external.uri)!)
                .buttonStyle(.plain)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(.gray, lineWidth: 1)
        )
    }
}
