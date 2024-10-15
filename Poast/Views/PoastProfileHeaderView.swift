//
//  PoastProfileHeaderView.swift
//  Poast
//
//  Created by Christopher Head on 8/23/23.
//

import SwiftUI

struct PoastProfileHeaderView: View {
    var profile: PoastProfileModel?

    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: profile?.banner ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.red)
                        .frame(height: 100)
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                .padding(.horizontal, 20)

                PoastAvatarView(size: .large, 
                                url: profile?.avatar ?? "")
                .offset(y: 50)

            }
            .padding(.bottom, 50)

            VStack {
                Text(profile?.displayName ?? "")
                    .font(.title)
                Text(profile?.handle ?? "")
            }
            .padding(.horizontal, 20)

            HStack {
                Spacer()

                VStack {
                    Text("\(profile?.followersCount ?? 0)")
                        .bold()
                    Text("followers")
                }

                Spacer()

                VStack {
                    Text("\(profile?.followsCount ?? 0)")
                        .bold()
                    Text("following")
                }

                Spacer()

                VStack {
                    Text("\(profile?.postsCount ?? 0)")
                        .bold()
                    Text("posts")

                }

                Spacer()
            }
            .padding(.horizontal, 20)

            Text(profile?.description ?? "")
                .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
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

    PoastProfileHeaderView(profile: profile)
}
