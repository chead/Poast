//
//  ActorProfileViewDetailedView.swift
//  Poast
//
//  Created by Christopher Head on 9/18/24.
//

import SwiftUI
import SwiftData
import SwiftBluesky

struct FeedView: View {
    @StateObject var feedViewModel: FeedViewModel
    @Binding var showingProfileHandle: String?
    @Binding var showingThreadURI: String?

    var body: some View {
        LazyVStack {
            if(feedViewModel.posts.isEmpty) {
                Text("Loading")
            }

            ForEach(feedViewModel.posts.map { FeedViewPostRow(feedViewPost: $0) }, id: \.self) { feedViewPostRow in
                FeedViewPostView(showingProfileHandle: $showingProfileHandle,
                                 showingThreadURI: $showingThreadURI,
                                 feedViewPost: feedViewPostRow.feedViewPost)
                .onAppear {
                    Task {
                        if feedViewModel.posts.lastIndex(of: feedViewPostRow.feedViewPost) == feedViewModel.posts.count - 1 {
//                            _ = await feedViewModel.updatePosts(cursor: feedViewPostRow.feedViewPost.post.indexedAt)
                        }
                    }
                }
            }
        }
    }
}

struct ProfileViewDetailedView: View {
    enum FeedType {
        case posts
        case replies
//        case media
//        case likes
//        case feeds
//        case lists
    }

    struct FeedViewFeedColumn: Identifiable, Hashable, Equatable {
        let id: FeedType
        let name: String
        let feedViewModel: FeedViewModel

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
        }

        static func == (lhs: ProfileViewDetailedView.FeedViewFeedColumn, rhs: ProfileViewDetailedView.FeedViewFeedColumn) -> Bool {
            lhs.id == rhs.id &&
            lhs.name == rhs.name
        }
    }

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var profileViewDetailedViewModel: ProfileViewDetailedViewModel

    @State var feedType: FeedType = .posts
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var hasAppeared: Bool = false
    @State var showingMoreConfirmationDialog: Bool = false
    @State var showingEditSheet: Bool = false

    @State var selectedFeed: FeedType?
    @State var visibleFeed: FeedType?

    @State var minimumFeedHeight: CGFloat = 250.0

    let feedViewFeedColumns: [FeedViewFeedColumn]

    init(session: SessionModel, modelContext: ModelContext, handle: String) {
        self._profileViewDetailedViewModel = StateObject(wrappedValue: ProfileViewDetailedViewModel(session: session,
                                                                                                    handle: handle))
        feedViewFeedColumns = [
            FeedViewFeedColumn(id: .posts,
                               name: "Posts",
                               feedViewModel: AuthorFeedViewModel(session: session,
                                                                  modelContext: modelContext,
                                                                  actor: handle,
                                                                  filter: .postsNoReplies)),
            FeedViewFeedColumn(id: .replies,
                               name: "Replies",
                               feedViewModel: AuthorFeedViewModel(session: session,
                                                                  modelContext: modelContext,
                                                                  actor: handle,
                                                                  filter: .postsWithReplies))
        ]
    }

    var body: some View {
        GeometryReader { scrollViewGeometryProxy in
            ScrollView {
                VStack {
                    if let profileViewDetailed = profileViewDetailedViewModel.profileViewDetailed {
                        ProfileViewDetailedHeaderView(profileViewDetailed: profileViewDetailed)
                    }

                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button("Posts") {
                                    selectedFeed = .posts
                                }
                                .id(FeedType.posts)
                                .foregroundStyle(visibleFeed == .posts ? .blue : .gray)
                                .padding(.horizontal, 20)

                                Button("Replies") {
                                    selectedFeed = .replies
                                }
                                .id(FeedType.replies)
                                .foregroundStyle(visibleFeed == .replies ? .blue : .gray)
                                .padding(.horizontal, 20)

//                                Button("Media") {
//                                    selectedFeed = .media
//                                }
//                                .id(FeedType.media)
//                                .foregroundStyle(visibleFeed == .media ? .blue : .gray)
//                                .padding(.horizontal, 20)
//
//                                if(isUserProfile()) {
//                                    Button("Likes") {
//                                        selectedFeed = .likes
//                                    }
//                                    .id(FeedType.likes)
//                                    .foregroundStyle(visibleFeed == .likes ? .blue : .gray)
//                                    .padding(.horizontal, 20)
//                                }
//
//                                Button("Feeds") {
//                                    selectedFeed = .feeds
//                                }
//                                .id(FeedType.feeds)
//                                .foregroundStyle(visibleFeed == .feeds ? .blue : .gray)
//                                .padding(.horizontal, 20)
//
//                                Button("Lists") {
//                                    selectedFeed = .lists
//                                }
//                                .id(FeedType.lists)
//                                .foregroundStyle(visibleFeed == .lists ? .blue : .gray)
//                                .padding(.horizontal, 20)
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        //                    .scrollPosition(id: $visibleFeed)
                        //                    .onChange(of: visibleFeed) { _, newValue in
                        //                        withAnimation {
                        //                            scrollViewProxy.scrollTo(newValue, anchor: .leading)
                        //                        }
                        //                    }
                    }

                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top) {
                                ForEach(feedViewFeedColumns, id: \.self) { feedViewFeedColumn in
                                    FeedView(feedViewModel: feedViewFeedColumn.feedViewModel, showingProfileHandle: $showingProfileHandle, showingThreadURI: $showingThreadURI)
                                        .frame(width: scrollViewGeometryProxy.size.width)
                                        .id(feedViewFeedColumn.id)
                                        .background {
                                            GeometryReader { proxy in
                                                Color.clear
                                                    .onChange(of: visibleFeed) { _, newVal in
                                                        if(feedViewFeedColumn.id == newVal) {
                                                            minimumFeedHeight = proxy.size.height
                                                        }
                                                    }
                                            }
                                        }
                                        .onAppear() {
                                            Task {
                                                _ = await feedViewFeedColumn.feedViewModel.refreshPosts()
                                            }
                                        }
                                }
                            }
                            .frame(minHeight: minimumFeedHeight)
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $visibleFeed)
                        .onChange(of: selectedFeed) { _, newValue in
                            withAnimation {
                                scrollViewProxy.scrollTo(newValue)
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(profileViewDetailedViewModel.profileViewDetailed?.handle ?? "")
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

                    if profileViewDetailedViewModel.canShareProfile(),
                       let profileShareURL = profileViewDetailedViewModel.profileShareURL() {
                        ShareLink(item: profileShareURL) {
                            Text("Share")
                        }
                    }

                    Button("Add to Lists") {
                    }
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .refreshable {
            _ = await feedViewFeedColumns.filter { $0.id == visibleFeed }.first?.feedViewModel.refreshPosts()
        }
        .task {
            if(!hasAppeared) {
                _ = await profileViewDetailedViewModel.getProfile()

                hasAppeared.toggle()
            }
        }
    }

    func isUserProfile() -> Bool {
        user.session?.account.handle == profileViewDetailedViewModel.profileViewDetailed?.handle
    }
}
