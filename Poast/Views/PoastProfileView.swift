//
//  PoastProfileView.swift
//  Poast
//
//  Created by Christopher Head on 8/9/23.
//

import SwiftUI

struct PoastProfileView: View {
    @StateObject var profileViewModel: PoastProfileViewModel

    @State var profile: PoastProfileModel?

    var body: some View {
        VStack {
            if let bannerURLString = self.profile?.banner,
               let bannerURL = URL(string: bannerURLString) {
                AsyncImage(url: bannerURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 200, height: 200)
                }
                .frame(height: 100)
            }

            if let avatarURLString = self.profile?.avatar,
               let avatarURL = URL(string: avatarURLString) {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {}
                    .frame(width: 50, height: 50)
            }

            Spacer()

            Text(self.profile?.handle ?? "")

            Spacer()
        }
        .onAppear() {
            Task {
                switch(await self.profileViewModel.getProfile()) {
                case .success(let profile):
                    self.profile = profile

                case .failure(_):
                    return
                }
            }
        }
    }
}

struct PoastProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PoastProfileView(profileViewModel: PoastProfileViewModel(session: nil, handle: ""))
    }
}
