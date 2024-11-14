//
//  PoastProfileEditView.swift
//  Poast
//
//  Created by Christopher Head on 11/1/24.
//

import SwiftUI

struct PoastProfileEditView: View {
    @EnvironmentObject var user: UserModel

    @StateObject var profileEditViewModel: ProfileEditViewModel

    @State var displayName: String = ""
    @State var description: String = ""
    @State var showingBannerConfirmationDialog = false
    @State var showingAvatarConfirmationDialog = false

    @Binding var showingEditSheet: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) {
                    showingEditSheet = false
                }

                Spacer ()

                Button("Save") {
                    
                }
            }
            .padding()
            .padding(.bottom, 10)

            ZStack {
                Button {
                    showingBannerConfirmationDialog = true
                } label: {
                    PoastProfileBannerView(url: URL(string: profileEditViewModel.profile?.banner ?? ""))
                        .padding()
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
                                    url: URL(string: profileEditViewModel.profile?.avatar ?? ""))
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
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 2)
                }
                .padding()

            TextEditor(text: $description)
                .scrollContentBackground(.hidden)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 2)
                }
                .padding()
        }
        .task {
            if let session = user.session, await profileEditViewModel.getProfile(session: session) == nil {
                displayName = profileEditViewModel.profile?.displayName ?? ""
                description = profileEditViewModel.profile?.description ?? ""
            }
        }
    }
}

//#Preview {
//    PoastProfileEditView()
//}
