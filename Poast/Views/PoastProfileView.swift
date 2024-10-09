//
//  PoastProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI

enum PoastProfileViewFeed {
    case posts
    case replies
    case media
    case likes
    case feeds
    case lists
}

struct PoastProfileView: View {
    @EnvironmentObject var user: PoastUser

    @ObservedObject var profileViewModel: PoastProfileViewModel

    @State var feed: PoastProfileViewFeed = .posts

    var body: some View {
        VStack {
            if let profile = profileViewModel.profile {
                PoastProfileHeaderView(profile: profileViewModel.profile)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()

                        Button("Posts") {
                            feed = .posts
                        }
                        .padding(.horizontal, 12)

                        Button("Replies") {
                            feed = .replies
                        }
                        .padding(.horizontal, 12)

                        Button("Media") {
                            feed = .media
                        }
                        .padding(.horizontal, 12)

                        Spacer()

                        Button("Likes") {
                            feed = .likes
                        }
                        .padding(.horizontal, 12)

                        Spacer()

                        Button("Feeds") {
                            feed = .feeds
                        }
                        .padding(.horizontal, 12)

                        Spacer()

                        Button("Lists") {
                            feed = .lists
                        }
                        .padding(.horizontal, 12)

                        Spacer()
                    }
                }

                Spacer()
                switch(feed) {
                case .posts:
                    PoastTimelineView(timelineViewModel: PoastAuthorTimelineViewModel(actor: profile.handle))

                case .replies:
                    Rectangle()
                        .fill(.blue)

                case .media:
                    Rectangle()
                        .fill(.green)

                case .likes:
                    Rectangle()
                        .fill(.purple)

                case .feeds:
                    Rectangle()
                        .fill(.pink)

                case .lists:
                    Rectangle()
                        .fill(.yellow)
                }

                Spacer()
            }
        }
        .onAppear() {
            Task {
                guard let session = user.session else {
                    return
                }

                _ = await self.profileViewModel.getProfile(session: session)
            }
        }
    }
}

#Preview {
    let account = PoastAccountModel(uuid: UUID(),
                                    created: Date(),
                                    handle: "@foobar.baz",
                                    host: URL(string: "https://bsky.social")!,
                                    session: nil)

    let session = PoastSessionModel(account: account,
                                    did: "",
                                    created: Date())

    let user = PoastUser()

    return PoastProfileView(profileViewModel: PoastProfileViewModel(handle: "Foobar"))
        .environmentObject(user)
}
