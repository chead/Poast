//
//  PoastProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI
import SwiftData

enum PoastProfileFeedType {
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
    @StateObject var authorFeedViewModel: PoastAuthorFeedViewModel
    @StateObject var repliesFeedViewModel: PoastAuthorFeedViewModel
    @StateObject var mediaFeedViewModel: PoastAuthorFeedViewModel
    @StateObject var likesFeedViewModel: PoastLikesFeedViewModel

    @State var feedType: PoastProfileFeedType = .posts
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()
    @State var hasAppeared: Bool = false
    @State var showingMoreConfirmationDialog: Bool = false

    var header: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: profileViewModel.profile?.banner ?? "")) { image in
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
                                url: profileViewModel.profile?.avatar ?? "")
                .offset(y: 50)
            }
            .padding(.bottom, 50)

            Text(profileViewModel.profile?.displayName ?? "")
                .font(.title)

            HStack {
                VStack {
                    Text("\(profileViewModel.profile?.followersCount ?? 0)")
                        .bold()
                    Text("followers")
                }

                Spacer()

                VStack {
                    Text("\(profileViewModel.profile?.followsCount ?? 0)")
                        .bold()
                    Text("following")
                }

                Spacer()

                VStack {
                    Text("\(profileViewModel.profile?.postsCount ?? 0)")
                        .bold()
                    Text("posts")
                }
            }
            .padding()

            Spacer()

            Text(profileViewModel.profile?.description ?? "")
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
        }
        .listRowSeparator(.hidden)
    }

    var menu: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("Posts") {
                    feedType = .posts
                }
                .padding(.horizontal, 20)

                Spacer()

                Button("Replies") {
                    feedType = .replies
                }
                .padding(.horizontal, 20)

                Spacer()

                Button("Media") {
                    feedType = .media
                }
                .padding(20)

                Spacer()

                if(isUserProfile()) {
                    Button("Likes") {
                        feedType = .likes
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                Button("Feeds") {
                    feedType = .feeds
                }
                .padding(.horizontal, 20)

                Spacer()

                Button("Lists") {
                    feedType = .lists
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    var feed: some View {
        switch(feedType) {
        case .posts:
            ForEach(authorFeedViewModel.posts) { post in
                PoastFeedPostView(feedViewModel: authorFeedViewModel,
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  post: post)
            }

        case .replies:
            ForEach(repliesFeedViewModel.posts) { post in
                PoastFeedPostView(feedViewModel: repliesFeedViewModel,
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  post: post)
            }

        case .media:
            ForEach(mediaFeedViewModel.posts) { post in
                PoastFeedPostView(feedViewModel: mediaFeedViewModel,
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  post: post)
            }

        case .likes:
            ForEach(likesFeedViewModel.posts) { post in
                PoastFeedPostView(feedViewModel: likesFeedViewModel,
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  post: post)
            }

        case .feeds:
            Rectangle()
                .fill(.pink)

        case .lists:
            Rectangle()
                .fill(.yellow)
        }
    }

    var body: some View {
        List {
            Section {
                header
            }
            Section {
                feed
            } header: {
                menu
            }
        }
        .listStyle(.plain)
        .navigationDestination(item: $showingProfileHandle) { profileHandle in
            if let session = user.session {
                PoastProfileView(profileViewModel: PoastProfileViewModel(session: session,
                                                                         handle: profileHandle),
                                 authorFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                               modelContext: modelContext,
                                                                               actor: profileHandle,
                                                                               filter: .postsNoReplies),
                                 repliesFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                                modelContext: modelContext,
                                                                                actor: profileHandle),
                                 mediaFeedViewModel: PoastAuthorFeedViewModel(session: session,
                                                                              modelContext: modelContext,
                                                                              actor: profileHandle,
                                                                              filter: .postsWithMedia),
                                 likesFeedViewModel: PoastLikesFeedViewModel(session: session,
                                                                             modelContext: modelContext,
                                                                             actor: profileHandle))
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingMoreConfirmationDialog = true
                } label: {
                    Image(systemName: "ellipsis")
                }
                .confirmationDialog("More", isPresented: $showingMoreConfirmationDialog) {
                    if(isUserProfile()) {
                        Button("Edit") {
                        }
                    }

                    if profileViewModel.canShareProfile(), let profileShareURL = profileViewModel.profileShareURL() {
                        ShareLink(item: profileShareURL) {
                            Text("Share")
                        }
                    }

                    Button("Add to Lists") {
                    }
                }
            }
        }
        .refreshable {
            switch(feedType) {
            case .posts:
                _ = await authorFeedViewModel.refreshPosts()

            case .replies:
                _ = await repliesFeedViewModel.refreshPosts()

            case .media:
                _ = await mediaFeedViewModel.refreshPosts()

            case .likes:
                _ = await likesFeedViewModel.refreshPosts()

            default:
                break
            }
        }
        .task {
            if(!hasAppeared) {
                _ = await profileViewModel.getProfile()
                _ = await authorFeedViewModel.refreshPosts()
                _ = await repliesFeedViewModel.refreshPosts()
                _ = await mediaFeedViewModel.refreshPosts()

                if(isUserProfile()) {
                    _ = await likesFeedViewModel.refreshPosts()
                }

                hasAppeared.toggle()
            }
        }
    }

    func isUserProfile() -> Bool {
        user.session?.account.handle == profileViewModel.profile?.handle
    }
}

//#Preview {
//    let modelContainer = try! ModelContainer(for: PoastAccountModel.self,
//                                             PoastPostLikeInteractionModel.self,
//                                             PoastPostRepostInteractionModel.self,
//                                             PoastThreadMuteInteractionModel.self,
//                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//
//    let account = PoastAccountModel(uuid: UUID(),
//                                    created: Date(),
//                                    handle: "@foobar.baz",
//                                    host: URL(string: "https://bsky.social")!,
//                                    session: nil)
//
//    let session = PoastSessionModel(account: account,
//                                    did: "",
//                                    created: Date())
//
//    let user = PoastUser(session: session)
//
//    let profileViewModel = PoastProfileViewModel(session: session, handle: "Foobar")
//
//    let profile = PoastProfileModel(did: "0",
//                                    handle: "foobar",
//                                    displayName: "FOOBAR",
//                                    desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed cursus risus non massa mollis, eget interdum ante volutpat.",
//                                    avatar: "",
//                                    banner: "",
//                                    followsCount: 1000,
//                                    followersCount: 1000,
//                                    postsCount: 2000,
//                                    labels: [])
//
//    profileViewModel.profile = profile
//
//    let profileView = PoastProfileView(profileViewModel: profileViewModel)
//        .modelContainer(modelContainer)
//        .environmentObject(user)
//
//    return profileView
//}
