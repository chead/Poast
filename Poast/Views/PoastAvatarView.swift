//
//  PoastAvatarView.swift
//  Poast
//
//  Created by Christopher Head on 2/16/24.
//

import SwiftUI

enum PoastAvatarSize: CGFloat {
    case small = 50.0
    case large = 100.0
}

struct PoastAvatarView: View {
    let size: PoastAvatarSize
    let url: String

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: url)) { image in
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
    PoastAvatarView(size: .large, url: "")
}
