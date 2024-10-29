//
//  PoastProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI
import SwiftData

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
        List {
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
                            }
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))

                            PoastAvatarView(size: .large,
                                            url: profile.avatar ?? "")
                            .offset(y: 50)

                        }
                        .padding(.bottom, 50)

                        Text(profile.displayName ?? "")
                            .font(.title)

                        HStack {
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
                        }
                        .padding()

                        Spacer()

                        Text(profile.description ?? "")
                            .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                    }
                    .listRowSeparator(.hidden)
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
                            .padding(.horizontal, 20)

                            Spacer()

                            Button("Replies") {
                                feed = .replies
                            }
                            .padding(.horizontal, 20)

                            Spacer()

                            Button("Media") {
                                feed = .media
                            }
                            .padding(20)

                            Spacer()

                            Button("Likes") {
                                feed = .likes
                            }
                            .padding(.horizontal, 20)

                            Spacer()

                            Button("Feeds") {
                                feed = .feeds
                            }
                            .padding(.horizontal, 20)

                            Spacer()

                            Button("Lists") {
                                feed = .lists
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .onAppear() {
                    refreshing = true
                }
            }
        }
        .listStyle(.plain)
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
    let modelContainer = try! ModelContainer(for: PoastAccountModel.self,
                                             PoastPostLikeInteractionModel.self,
                                             PoastPostRepostInteractionModel.self,
                                             PoastThreadMuteInteractionModel.self,
                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

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
                                    desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed cursus risus non massa mollis, eget interdum ante volutpat.",
                                    avatar: "",
                                    banner: "",
                                    followsCount: 1000,
                                    followersCount: 1000,
                                    postsCount: 2000,
                                    labels: [])

    profileViewModel.profile = profile

    let profileView = PoastProfileView(profileViewModel: profileViewModel)
        .modelContainer(modelContainer)
        .environmentObject(user)

    return profileView
}
