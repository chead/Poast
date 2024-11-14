//
//  PostHeaderView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PostHeaderView: View {
    let authorName: String
    let timeAgo: String

    var body: some View {
        HStack {
            Text(authorName)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Text(timeAgo)
        }
    }
}

#Preview {
    PostHeaderView(authorName: "Foo", timeAgo: "13 minutes ago")
}
