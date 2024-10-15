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
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: PoastUser

    @StateObject var profileViewModel: PoastProfileViewModel

    @State var feed: PoastProfileViewFeed = .posts

    var body: some View {
        ScrollView {
            if let profile = profileViewModel.profile {
                PoastProfileHeaderView(profile: profile)

                Spacer()

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
                    if let session = user.session {
                        PoastTimelineView(timelineViewModel: PoastAuthorTimelineViewModel(session: session, modelContext: modelContext, actor: profile.handle), showingToolbar: false, verticalLayout: .stack)
                            .padding(20)
                    } else {
                        EmptyView()
                    }

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
        .listStyle(.plain)
        .onAppear() {
            Task {
                _ = await self.profileViewModel.getProfile()
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

    let user = PoastUser(session: session)

    let profileViewModel = PoastProfileViewModel(session: session, handle: "Foobar")

    let profile = PoastProfileModel(did: "0",
                                    handle: "foobar",
                                    displayName: "FOOBAR",
                                    desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed cursus risus non massa mollis, eget interdum ante volutpat. Sed cursus risus non massa mollis, eget interdum ante volutpat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a tortor dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean a felis sit amet elit viverra porttitor. In hac habitasse platea dictumst. Nulla mollis luctus sagittis. Vestibulum volutpat ipsum vel elit accumsan dapibus. Vivamus quis erat consequat, auctor est id, malesuada sem.",
                                    avatar: "",
                                    banner: "",
                                    followsCount: 1000,
                                    followersCount: 1000,
                                    postsCount: 2000,
                                    labels: [])

    profileViewModel.profile = profile

    let profileView = PoastProfileView(profileViewModel: profileViewModel)
        .environmentObject(user)

    return profileView
}
