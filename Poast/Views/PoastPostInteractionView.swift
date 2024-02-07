//
//  PoastPostInteractionView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastPostInteractionView: View {
    @Binding var postViewModel: PoastPostViewModel

    let replyCount: Int
    let repostCount: Int
    let likeCount: Int

    var body: some View {
        HStack {
            Button(action: {}, label: {
                HStack {
                    Image(systemName: "bubble")
                    Text("\(replyCount)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                HStack {
                    Image(systemName: "repeat")
                    Text("\(repostCount)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                HStack {
                    Image(systemName: "heart")
                    Text("\(likeCount)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                Image(systemName: "ellipsis")
            })
        }
    }
}

#Preview {
    return PoastPostInteractionView(postViewModel: .constant(PoastPostViewModel()),
                                    replyCount: 1,
                                    repostCount: 2,
                                    likeCount: 3)
}
