//
//  PoastPostInteractionView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastPostInteractionView: View {
    @EnvironmentObject var session: PoastSessionObject

    @Binding var postViewModel: PoastPostViewModel

    let replyCount: Int
    let repostCount: Int
    let likeCount: Int

    var body: some View {
        HStack {
            Button(action: {}, label: {
                HStack {
                    Image(systemName: "bubble")
                    Text("\(self.replyCount)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                HStack {
                    Image(systemName: "repeat")
                    Text("\(self.repostCount)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                HStack {
                    Image(systemName: "heart")
                    Text("\(self.likeCount)")
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
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = UUID()
    session.did = ""

    let post = PoastFeedPostViewModel(id: "",
                                      uri: "",
                                      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed molestie leo felis, ut ultrices est euismod vitae. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce bibendum iaculis augue, eget luctus purus dapibus ut. Morbi congue, nibh lacinia consequat tempus, lacus nisl eleifend ligula, quis dapibus sem diam ac ex.",
                                      author: PoastProfileModel(did: "",
                                                                handle: "foobar.net",
                                                                displayName: "Foobar",
                                                                description: "Lorem Ipsum",
                                                                avatar: "https://i.ytimg.com/vi/uk5gQlBDCaw/maxresdefault.jpg",
                                                                banner: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/7ed1f8d6-5026-4dca-9726-e1a21945f876/db5dby9-17f63eb7-68b2-4468-9a4e-fdca0ed1fd66.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzdlZDFmOGQ2LTUwMjYtNGRjYS05NzI2LWUxYTIxOTQ1Zjg3NlwvZGI1ZGJ5OS0xN2Y2M2ViNy02OGIyLTQ0NjgtOWE0ZS1mZGNhMGVkMWZkNjYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.zc5xkLwVNH_XO4hTBl7u-1-4WolXlaIfpInSRqSer4A",
                                                                followsCount: 10,
                                                                followersCount: 123,
                                                                postsCount: 4123,
                                                                labels: []),
                                      replyCount: 1,
                                      likeCount: 0,
                                      repostCount: 10,
                                      root: nil,
                                      parent: nil,
                                      date: Date())

    return PoastPostInteractionView(postViewModel: .constant(PoastPostViewModel()), replyCount: 1, repostCount: 2, likeCount: 3)
        .environmentObject(session)
}
