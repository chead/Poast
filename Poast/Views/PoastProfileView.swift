//
//  PoastProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI

enum PoastProfileViewFeedType {
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

    @State var feed: PoastProfileViewFeedType = .posts
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()
    @State var refreshing: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                if let profile = profileViewModel.profile {
                    Section {
                        VStack {
                            ZStack {
                                AsyncImage(url: URL(string: profile.banner ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(.clear)
                                        .frame(height: 100)
                                }
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .padding(.horizontal, 16)

                                PoastAvatarView(size: .large,
                                                url: profile.avatar ?? "")
                                .offset(y: 50)

                            }
                            .padding(.top, 20)
                            .padding(.bottom, 50)

                            Text(profile.displayName ?? "")
                                .font(.title)

                            HStack {
                                Spacer()

                                VStack {
                                    Text("\(profile.followersCount ?? 0)")
                                        .bold()
                                    Text("followers")
                                }

                                Spacer()

                                VStack {
                                    Text("\(profile.followsCount ?? 0)")
                                        .bold()
                                    Text("following")
                                }

                                Spacer()

                                VStack {
                                    Text("\(profile.postsCount ?? 0)")
                                        .bold()
                                    Text("posts")

                                }

                                Spacer()
                            }
                            .padding(.horizontal, 20)

                            Text(profile.description ?? "")
                                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                                .padding(20)
                        }
                    }

                    Section {
                        switch(feed) {
                        case .posts:
                            if let session = user.session {
                                PoastTimelineView(timelineViewModel: PoastAuthorTimelineViewModel(session: session,
                                                                                                  modelContext: modelContext,
                                                                                                  actor: profile.handle),
                                                  showingProfileHandle: $showingProfileHandle,
                                                  showingThreadURI: $showingThreadURI,
                                                  interacted: $interacted,
                                                  refreshing: $refreshing)
                                .padding(.horizontal, 20)
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
                    } header: {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button("Posts") {
                                    feed = .posts
                                }
                                .padding(20)

                                Spacer()

                                Button("Replies") {
                                    feed = .replies
                                }
                                .padding(20)

                                Spacer()

                                Button("Media") {
                                    feed = .media
                                }
                                .padding(20)

                                Spacer()

                                Button("Likes") {
                                    feed = .likes
                                }
                                .padding(20)

                                Spacer()

                                Button("Feeds") {
                                    feed = .feeds
                                }
                                .padding(20)

                                Spacer()

                                Button("Lists") {
                                    feed = .lists
                                }
                                .padding(20)
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                }
            }
        }
        .navigationDestination(item: $showingProfileHandle) { profileHandle in
            if let session = user.session {
                PoastProfileView(profileViewModel: PoastProfileViewModel(session: session, handle: profileHandle))
            } else {
                EmptyView()
            }
        }
        .navigationDestination(item: $showingThreadURI) { threadURI in
            PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
                            interacted: $interacted)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(profileViewModel.profile?.handle ?? "")
            }
        }
        .onAppear() {
            Task {
                _ = await self.profileViewModel.getProfile()
            }
        }
        .refreshable {
            refreshing = true
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
