//
//  PoastPostFeedView.swift
//  Poast
//
//  Created by Christopher Head on 10/24/24.
//

import SwiftUI

struct PoastFeedView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var user: PoastUser

    @State var showingComposerView: Bool = false
    @State var showingProfileHandle: String? = nil
    @State var showingThreadURI: String? = nil
    @State var interacted: Date = Date()
    @State var refreshing: Bool = false

    var body: some View {
        ScrollView {
            if let session = user.session {
                PoastTimelineView(timelineViewModel: PoastFeedTimelineViewModel(session: session,
                                                                                modelContext: modelContext,
                                                                                algorithm: ""),
                                  showingProfileHandle: $showingProfileHandle,
                                  showingThreadURI: $showingThreadURI,
                                  interacted: $interacted,
                                  refreshing: $refreshing)
                .padding(.horizontal, 20)
            }
        }
        .navigationDestination(item: $showingProfileHandle) { profileHandle in
            if let session = user.session {
                PoastProfileView(profileViewModel: PoastProfileViewModel(session: session, handle: profileHandle))
            } else {
                EmptyView()
            }
        }
        .navigationDestination(item: $showingThreadURI) { threadURI in
            PoastThreadView(threadViewModel: PoastThreadViewModel(uri: threadURI),
                            interacted: $interacted)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Poast")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingComposerView = true
                } label: {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showingComposerView) {
                    EmptyView()
                }
            }
        }
        .refreshable {
            refreshing = true
        }
    }
}

#Preview {
    PoastFeedView()
}
