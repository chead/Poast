//
//  PoastProfileEditView.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import SwiftUI

struct PoastProfileEditView: View {
    @StateObject var profileEditViewModel: PoastProfileEditViewModel

    @State var banner: String?
    @State var avatar: String?
    @State var displayName: String
    @State var description: String
    @State var showingBannerConfirmationDialog = false
    @State var showingAvatarConfirmationDialog = false

    @Binding var showingEditSheet: Bool

    let profile: PoastProfileModel

    init(profile: PoastProfileModel, showingEditSheet: Binding<Bool>, profileEditViewModel: PoastProfileEditViewModel) {

        self.profile = profile
        self._showingEditSheet = showingEditSheet
        self.banner = profile.banner
        self.avatar = profile.avatar
        self.displayName = profile.displayName ?? ""
        self.description = profile.description ?? ""

        self._profileEditViewModel = StateObject(wrappedValue: profileEditViewModel)
    }

    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) {
                    showingEditSheet = false
                }

                Spacer ()

                Button("Save") {}
            }
            .padding()
            .padding(.bottom, 10)

            ZStack {
                Button {
                    showingBannerConfirmationDialog = true
                } label: {
                    AsyncImage(url: URL(string: banner ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(.clear)
                    }
                    .frame(height: 100)
                }
                .confirmationDialog("Banner", isPresented: $showingBannerConfirmationDialog) {
                    Button("Upload from Library") {
                    }
                    Button("Remove") {
                    }
                }

                Button {
                    showingAvatarConfirmationDialog = true
                } label: {
                    PoastAvatarView(size: .large,
                                    url: avatar ?? "")
                    .offset(y: 50)
                }
                .confirmationDialog("Avatar", isPresented: $showingAvatarConfirmationDialog) {
                    Button("Upload from Library") {
                    }
                    Button("Remove") {
                    }
                }
            }
            .padding(.bottom, 50)

            TextField("", text: $displayName)
                .font(.title)
                .multilineTextAlignment(.center)
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()

            TextEditor(text: $description)
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()
        }
    }
}

//#Preview {
//    PoastProfileEditView()
//}
