//
//  PoastPostComposeView.swift
//  Poast
//
//  Created by Christopher Head on 10/24/24.
//

import SwiftUI

struct PoastPostComposeView: View {
    enum FocusedField {
        case textEditor
    }

    @State var showingDiscardConfirmationDialog: Bool = false
    @State var showingLanguageConfirmationDialog: Bool = false
    @State private var postText: String = ""

    @FocusState private var focusedField: FocusedField?

    @Binding var showingComposeView: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) {
                    if(postText.isEmpty) {
                        showingComposeView = false
                    } else {
                        showingDiscardConfirmationDialog = true
                    }
                }
                .confirmationDialog("Discard draft?", isPresented: $showingDiscardConfirmationDialog) {
                    Button("Discard draft", role: .destructive) {
                        showingComposeView = false
                    }
                }

                Spacer ()

                Button {

                } label: {
                    Image(systemName: "exclamationmark.triangle")
                }

                Spacer()

                Button("Post") {}
            }
            .padding()

            TextEditor(text: $postText)
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .focused($focusedField, equals: .textEditor)
                .padding()

            HStack {
                Button {

                } label: {
                    Image(systemName: "photo")
                }
                .padding(8)

                Button {

                } label: {
                    Image(systemName: "video")
                }
                .padding(8)

                Button {

                } label: {
                    Image(systemName: "film")
                }
                .padding(8)

                Spacer()

                Button("English") {}
                    .confirmationDialog("Language",
                                        isPresented: $showingLanguageConfirmationDialog,
                                        titleVisibility: .hidden) {
                        Button("English") {}
                        Button("Japanese") {}
                        Button("Portugese") {}
                        Button("German") {}
                        Button("Other") {}
                    }

                Text("\(300 - postText.count)")
                    .frame(width: 80)
            }
            .padding(.horizontal)
        }
        .onAppear {
            focusedField = .textEditor
        }

        Spacer()
    }
}

#Preview {
    PoastPostComposeView(showingComposeView: .constant(true))
}
