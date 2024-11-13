//
//  PoastProfileBannerView.swift
//  Poast
//
//  Created by Christopher Head on 11/11/24.
//

import SwiftUI

struct PoastProfileBannerView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(.clear)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}
