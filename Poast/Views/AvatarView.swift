//
//  AvatarView.swift
//  Poast
//
//  Created by Christopher Head on 2/16/24.
//

import SwiftUI

struct AvatarView: View {
    enum Size: CGFloat {
        case small = 50.0
        case large = 100.0
    }

    let size: Size
    let url: URL?

    var body: some View {
        VStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.clear)
                    .frame(width: size.rawValue, height: size.rawValue)
            }
            .frame(width: size.rawValue, height: size.rawValue)
            .clipShape(Circle())
        }
    }
}

#Preview {
    AvatarView(size: .large, url: URL(string: ""))
}
