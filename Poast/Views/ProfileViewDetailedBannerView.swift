//
//  ProfileBannerView.swift
//  Poast
//
//  Created by Christopher Head on 11/11/24.
//

import SwiftUI
import NukeUI

struct ProfileViewDetailedBannerView: View {
    let url: URL?

    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}
