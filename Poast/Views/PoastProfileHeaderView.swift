//
//  PoastProfileHeaderView.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import SwiftUI

struct PoastProfileHeaderView: View {
    let profile: ActorProfileViewModel

    var body: some View {
        VStack {
            ZStack {
                if let banner = profile.banner {
                    AsyncImage(url: URL(string: banner)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(.clear)
                    }
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                }

                if let avatar = profile.avatar {
                    PoastAvatarView(size: .large,
                                    url: URL(string: avatar))
                    .offset(y: 50)
                }
            }
            .padding(.bottom, 50)

            Text(profile.displayName ?? profile.handle)
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
}
