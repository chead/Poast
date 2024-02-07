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

                AsyncImage(url: URL(string: profile?.avatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 100, height: 100)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .offset(y: 50)

            }
            .padding(.bottom, 50)

            Text(profile?.displayName ?? "")
                .font(.title)
            Text(profile?.handle ?? "")

            HStack {
                Spacer()

                Text("\(profile?.followersCount ?? 0)")
                    .bold()
                Text("followers")

                Spacer()
                
                Text("\(profile?.followsCount ?? 0)")
                    .bold()
                Text("following")
                
                Spacer()
                
                Text("\(profile?.postsCount ?? 0)")
                    .bold()
                Text("posts")
                
                Spacer()
            }
            ScrollView {
                Text(profile?.description ?? "")
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let profile = PoastProfileModel(did: "0",
                                    handle: "foobar",
                                    displayName: "FOOBAR",
                                    description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed cursus risus non massa mollis, eget interdum ante volutpat. Sed cursus risus non massa mollis, eget interdum ante volutpat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a tortor dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean a felis sit amet elit viverra porttitor. In hac habitasse platea dictumst. Nulla mollis luctus sagittis. Vestibulum volutpat ipsum vel elit accumsan dapibus. Vivamus quis erat consequat, auctor est id, malesuada sem.",
                                    avatar: "",
                                    banner: "",
                                    followsCount: 0,
                                    followersCount: 1,
                                    postsCount: 2,
                                    labels: [])

    return PoastProfileHeaderView(profile: profile)
}
