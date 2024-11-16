//
//  ThreadViewPostView.swift
//  Poast
//
//  Created by Christopher Head on 11/16/24.
//

import SwiftUI
import SwiftBluesky

struct ThreadViewPostView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: UserModel

    @StateObject var threadViewPostViewModel: ThreadViewPostViewModel

    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil

    @Binding var interacted: Date

    var body: some View {
        Text("Hello, World!")

//        threadViewPostViewModel.threadPost?.post
    }
}

//#Preview {
//    ThreadViewPostView()
//}
