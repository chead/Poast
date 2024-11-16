//
//  ProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI
import SwiftData
import SwiftBluesky

enum ProfileFeedType {
    case posts
    case replies
    case media
    case likes
    case feeds
    case lists
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var profileViewModel: ProfileViewViewModel
    @StateObject var authorFeedViewModel: AuthorFeedViewModel
    @StateObject var repliesFeedViewModel: AuthorFeedViewModel
    @StateObject var mediaFeedViewModel: AuthorFeedViewModel
    @StateObject var likesFeedViewModel: LikesFeedViewModel

    @State var feedType: ProfileFeedType = .posts
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()
    @State var hasAppeared: Bool = false
    @State var showingMoreConfirmationDialog: Bool = false
    @State var showingEditSheet: Bool = false

    var menu: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("Posts") {
                    feedType = .posts
                }
                .foregroundStyle(feedType == .posts ? .blue : .gray)
                .padding(.horizontal, 20)


                Spacer()

                Button("Replies") {
                    feedType = .replies
                }
                .foregroundStyle(feedType == .replies ? .blue : .gray)
                .padding(.horizontal, 20)

                Spacer()

                Button("Media") {
                    feedType = .media
                }
                .foregroundStyle(feedType == .media ? .blue : .gray)
                .padding(20)

                Spacer()

                if(isUserProfile()) {
                    Button("Likes") {
                        feedType = .likes
                    }
                    .foregroundStyle(feedType == .likes ? .blue : .gray)
                    .padding(.horizontal, 20)
                }

                Spacer()

                Button("Feeds") {
                    feedType = .feeds
                }
                .foregroundStyle(feedType == .feeds ? .blue : .gray)
                .padding(.horizontal, 20)

                Spacer()

                Button("Lists") {
                    feedType = .lists
                }
                .foregroundStyle(feedType == .lists ? .blue : .gray)
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    var feed: some View {
        switch(feedType) {
        case .posts:
            ForEach(authorFeedViewModel.posts) { post in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted,
                                 feedViewPost: post)
            }

        case .replies:
            ForEach(repliesFeedViewModel.posts) { post in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted,
                                 feedViewPost: post)
            }

        case .media:
            ForEach(mediaFeedViewModel.posts) { post in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted,
                                 feedViewPost: post)
            }

        case .likes:
            ForEach(likesFeedViewModel.posts) { post in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 interacted: $interacted,
                                 feedViewPost: post)
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
                if let profile = profileViewModel.profile {
                    ProfileHeaderView(profile: profile)
                }
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
                ProfileView(profileViewModel: ProfileViewViewModel(session: session,
                                                                         handle: profileHandle),
                                 authorFeedViewModel: AuthorFeedViewModel(session: session,
                                                                               modelContext: modelContext,
                                                                               actor: profileHandle,
                                                                               filter: .postsNoReplies),
                                 repliesFeedViewModel: AuthorFeedViewModel(session: session,
                                                                                modelContext: modelContext,
                                                                                actor: profileHandle),
                                 mediaFeedViewModel: AuthorFeedViewModel(session: session,
                                                                              modelContext: modelContext,
                                                                              actor: profileHandle,
                                                                              filter: .postsWithMedia),
                                 likesFeedViewModel: LikesFeedViewModel(session: session,
                                                                             modelContext: modelContext,
                                                                             actor: profileHandle))
            } else {
                EmptyView()
            }
        }
        .navigationDestination(item: $showingThreadURI) { threadURI in
            PoastThreadView(threadViewModel: ThreadViewModel(uri: threadURI),
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
                            showingEditSheet = true
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
        .sheet(isPresented: $showingEditSheet) {
            if let profile = profileViewModel.profile {
                ProfileEditView(profileEditViewModel: ProfileEditViewModel(handle: profile.handle),
                                     showingEditSheet: $showingEditSheet)
            } else {
                EmptyView()
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

                hasAppeared.toggle()
            }
        }
        .onChange(of: feedType) { oldValue, newValue in
            switch(newValue) {
            case .posts:
                if(authorFeedViewModel.posts.isEmpty) {
                    Task {
                        _ = await authorFeedViewModel.refreshPosts()
                    }
                }

            case .replies:
                if(repliesFeedViewModel.posts.isEmpty) {
                    Task {
                        _ = await repliesFeedViewModel.refreshPosts()
                    }
                }

            case .media:
                if(mediaFeedViewModel.posts.isEmpty) {
                    Task {
                        _ = await mediaFeedViewModel.refreshPosts()
                    }
                }

            case .likes:
                if(likesFeedViewModel.posts.isEmpty) {
                    Task {
                        _ = await likesFeedViewModel.refreshPosts()
                    }
                }

            default:
                break
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
