//
//  AvatarView.swift
//  Poast
//
//  Created by Christopher Head on 2/16/24.
//

import SwiftUI
import NukeUI

struct AvatarView: View {
    enum Size: CGFloat {
        case small = 25.0
        case medium = 50.0
        case large = 100.0
    }

    let size: Size
    let url: URL?

    var body: some View {
        VStack {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: size.rawValue, height: size.rawValue)
            .clipShape(Circle())
        }
    }
}

#Preview {
    AvatarView(size: .large, url: URL(string: ""))
}
