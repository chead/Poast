//
//  PoastPostInteractionView.swift
//  Poast
//
//  Created by Christopher Head on 2/2/24.
//

import SwiftUI

struct PoastPostInteractionView: View {
    @EnvironmentObject var user: PoastUser

    @Binding var postViewModel: PoastPostViewModel

    let postURI: String
    let postCID: String
    let replyCount: Int
    let repostCount: Int
    let likeCount: Int

    let replyDisabled: Bool
    let reposted: String?
    let liked: String?

    @State var repostDelta = 0
    @State var likeDelta = 0

    var body: some View {
        HStack {
            Button(action: {

            }, label: {
                HStack {
                    Image(systemName: "bubble")
                    Text("\(replyCount)")
                }
            })
            .disabled(replyDisabled)

            Spacer()

            Button(action: {
                
            }, label: {
                HStack {
                    if(reposted != nil || repostDelta > 0) {
                        Image(systemName: "repeat")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "repeat")
                    }

                    Text("\(repostCount + repostDelta)")
                }
            })

            Spacer()

            Button(action: {
                Task {
                    if(liked != nil || likeDelta > 0) {

                    } else {
                        guard let accountSession = user.accountSession else { return }
                        
                        switch(await postViewModel.likePost(session: accountSession.session,
                                                            uri: postURI,
                                                            cid: postCID)) {
                        case.success(_):
                            likeDelta += 1

                        case .failure(_):
                            break
                        }
                    }
                }
            }, label: {
                HStack {
                    if(liked != nil || likeDelta > 0) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                    }

                    Text("\(likeCount + likeDelta)")
                }
            })

            Spacer()

            Button(action: {}, label: {
                Image(systemName: "ellipsis")
            })
        }
        .task {

        }
    }
}

#Preview {
    return PoastPostInteractionView(postViewModel: .constant(PoastPostViewModel()),
                                    postURI: "",
                                    postCID: "",
                                    replyCount: 1,
                                    repostCount: 2,
                                    likeCount: 3,
                                    replyDisabled: false,
                                    reposted: nil,
                                    liked: "")
}
