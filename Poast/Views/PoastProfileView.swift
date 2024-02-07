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

    var profileViewModel: PostProfileViewModeling

    @State var profile: PoastProfileModel?
    @State var feed: PoastProfileViewFeed = .posts

    var body: some View {
        VStack {
            PoastProfileHeaderView(profile: profile)
                    
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
            .padding(.top, 10)

            switch(feed) {
            case .posts:
                PoastTimelineView(timelineViewModel: PoastAuthorTimelineViewModel(actor: profileViewModel.handle))

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
        .onAppear() {
            Task {
                guard let session = user.accountSession?.session else {
                    return
                }

                switch(await self.profileViewModel.getProfile(session: session)) {
                case .success(let profile):
                    self.profile = profile

                case .failure(_):
                    break
                }
            }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let account = PoastAccountObject(context: managedObjectContext)

    account.created = Date()
    account.handle = "Foobar"
    account.host = URL(string: "https://bsky.social")!
    account.uuid = UUID()

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = account.uuid!
    session.did = ""

    return PoastProfileView(profileViewModel: PoastProfileViewPreviewModel(handle: "Foobar"))
        .environmentObject(session)
}
