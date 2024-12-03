//
//  ProfileViewDetailedHeaderView.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import SwiftUI
import SwiftBluesky
import NukeUI

struct ProfileViewDetailedHeaderView: View {
    let profileViewDetailed: Bsky.BskyActor.ProfileViewDetailed

    var body: some View {
        VStack {
            ZStack {
                if let banner = profileViewDetailed.banner {
                    ProfileViewDetailedBannerView(url: URL(string: banner))
                }

                if let avatar = profileViewDetailed.avatar {
                    AvatarView(size: .large,
                                    url: URL(string: avatar))
                    .offset(y: 50)
                }
            }
            .padding(.bottom, 50)

            Text(profileViewDetailed.displayName ?? profileViewDetailed.handle)
                .font(.title)

            HStack {
                VStack {
                    Text("\(profileViewDetailed.followersCount ?? 0)")
                        .bold()
                    Text("followers")
                }

                Spacer()

                VStack {
                    Text("\(profileViewDetailed.followsCount ?? 0)")
                        .bold()
                    Text("following")
                }

                Spacer()

                VStack {
                    Text("\(profileViewDetailed.postsCount ?? 0)")
                        .bold()
                    Text("posts")
                }
            }
            .padding()

            Spacer()

            Text(profileViewDetailed.description ?? "")
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
        }
    }
}
